/// Minimal auth user for domain/routing (no Firebase types in domain).
/// Mapped from Firebase User in the data layer.
class AuthUser {
  final String uid;
  final String email;
  final bool emailVerified;

  const AuthUser({
    required this.uid,
    required this.email,
    required this.emailVerified,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          emailVerified == other.emailVerified;

  @override
  int get hashCode => uid.hashCode ^ email.hashCode ^ emailVerified.hashCode;
}
