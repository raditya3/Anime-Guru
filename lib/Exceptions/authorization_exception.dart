class AuthorizationException implements Exception {
  final String cause;
  AuthorizationException({required this.cause});
}