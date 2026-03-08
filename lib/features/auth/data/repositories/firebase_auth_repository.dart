import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../../core/errors/auth_exception.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

/// Firebase implementation of [AuthRepository].
/// Maps Firebase User to [AuthUser], Firestore docs to [UserProfile].
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    firebase_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const String _usersCollection = 'users';

  @override
  Stream<AuthUser?> get authStateChanges =>
      _auth.authStateChanges().map(_authUserFromFirebaseUser);

  @override
  Future<AuthUser?> get currentUser async {
    final user = _auth.currentUser;
    return _authUserFromFirebaseUser(user);
  }

  AuthUser? _authUserFromFirebaseUser(firebase_auth.User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email ?? '',
      emailVerified: user.emailVerified,
    );
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user == null) throw const AuthException('Sign up failed');

      if (displayName != null && displayName.trim().isNotEmpty) {
        await user.updateDisplayName(displayName.trim());
      }

      final profile = UserProfile(
        uid: user.uid,
        email: user.email ?? email,
        displayName: displayName?.trim(),
        emailVerified: user.emailVerified,
        createdAt: DateTime.now(),
      );
      await createOrUpdateUserProfile(profile);

      await user.sendEmailVerification();
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code}');
      throw AuthException(_messageFromFirebaseCode(e.code), e.code);
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_messageFromFirebaseCode(e.code), e.code);
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException('No user signed in');
    try {
      await user.sendEmailVerification();
      print('Email verification sent');
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code}');
      throw AuthException(_messageFromFirebaseCode(e.code), e.code);
    }
  }

  @override
  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _firestore.collection(_usersCollection).doc(uid).get();
    if (doc.data() == null) return null;
    return _userProfileFromDoc(doc);
  }

  @override
  Future<void> createOrUpdateUserProfile(UserProfile profile) async {
    final data = <String, dynamic>{
      'email': profile.email,
      'emailVerified': profile.emailVerified,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (profile.displayName != null) {
      data['displayName'] = profile.displayName;
    }
    await _firestore
        .collection(_usersCollection)
        .doc(profile.uid)
        .set(data, SetOptions(merge: true));
  }

  UserProfile _userProfileFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    final createdAt = d['createdAt'] as Timestamp?;
    return UserProfile(
      uid: doc.id,
      email: d['email'] as String? ?? '',
      displayName: d['displayName'] as String?,
      emailVerified: d['emailVerified'] as bool? ?? false,
      createdAt: createdAt?.toDate(),
    );
  }

  String _messageFromFirebaseCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
