import '../entities/auth_user.dart';
import '../entities/user_profile.dart';

/// Auth abstraction; no Firebase types in signature.
/// Implemented by [FirebaseAuthRepository] in data layer.
abstract class AuthRepository {
  Stream<AuthUser?> get authStateChanges;

  Future<AuthUser?> get currentUser;

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> sendEmailVerification();

  /// Reloads the current user from the server (e.g. to refresh [AuthUser.emailVerified])
  /// and returns the updated user. Implementations may also emit this user to [authStateChanges].
  Future<AuthUser?> reloadCurrentUser();

  Future<UserProfile?> getUserProfile(String uid);

  Future<void> createOrUpdateUserProfile(UserProfile profile);
}
