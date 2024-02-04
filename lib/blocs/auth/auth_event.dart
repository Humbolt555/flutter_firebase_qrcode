part of 'auth_bloc.dart';

sealed class AuthEvent {}

class AuthEventLogin extends AuthEvent {
  AuthEventLogin({required this.email, required this.password});
  final String email;
  final String password;
}

class AuthEventLogout extends AuthEvent {}

class AuthEventError extends AuthEvent {}
