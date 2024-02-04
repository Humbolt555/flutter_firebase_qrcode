part of 'auth_bloc.dart';

sealed class AuthState {}

final class AuthStateLoggedOut extends AuthState {}

final class AuthStateLoggedIn extends AuthState {}

final class AuthStateLoading extends AuthState {}

final class AuthStateError extends AuthState {
  AuthStateError(this.error);
  final String error;
}
