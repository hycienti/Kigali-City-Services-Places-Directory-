/// Thrown when a listing operation fails (e.g. Firestore permission, network).
class ListingException implements Exception {
  const ListingException(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  String toString() =>
      'ListingException: $message${code != null ? ' (code: $code)' : ''}';
}
