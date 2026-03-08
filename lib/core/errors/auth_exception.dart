/// Domain-friendly auth errors (mapped from Firebase Auth exceptions in data layer).
class AuthException implements Exception {
  const AuthException(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  String toString() => 'AuthException: $message${code != null ? ' (code: $code)' : ''}';
}
