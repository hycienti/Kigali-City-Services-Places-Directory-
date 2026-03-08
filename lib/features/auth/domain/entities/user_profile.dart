/// User profile stored in Firestore (users/{uid}).
/// Plain Dart; no Flutter/Firebase imports.
class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final bool emailVerified;
  final DateTime? createdAt;

  const UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    required this.emailVerified,
    this.createdAt,
  });

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    bool? emailVerified,
    DateTime? createdAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          displayName == other.displayName &&
          emailVerified == other.emailVerified &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      uid.hashCode ^
      email.hashCode ^
      displayName.hashCode ^
      emailVerified.hashCode ^
      createdAt.hashCode;
}
