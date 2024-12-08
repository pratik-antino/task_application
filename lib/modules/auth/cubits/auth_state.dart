part of 'auth_cubit.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthUnauthenticated extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String token;
  final String userId;

  AuthAuthenticated({required this.token, required this.userId});
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

