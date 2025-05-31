// ========== AUTH STATE ==========
abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthUnauthenticated extends AuthState {}
class AuthAuthenticated extends AuthState {
  final String accessToken;
  AuthAuthenticated(this.accessToken);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}