import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

export 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthStateLoggedOut()) {
    on<AuthEventLogin>(_login);

    on<AuthEventLogout>(_logout);
  }

  FirebaseAuth auth = FirebaseAuth.instance;

  void _login<AuthEventLogin>(event, emit) async {
    emit(AuthStateLoading());
    try {
      await auth.signInWithEmailAndPassword(
          email: event.email, password: event.password);
      emit(AuthStateLoggedIn());
    } on FirebaseAuthException catch (e) {
      emit(AuthStateError(e.message.toString()));
    } catch (e) {
      emit(AuthStateError(e.toString()));
    }
  }

  void _logout(event, emit) async {
    emit(AuthStateLoading());
    try {
      await auth.signOut();
      emit(AuthStateLoggedOut());
    } on FirebaseAuthException catch (e) {
      emit(AuthStateError(e.message.toString()));
    } catch (e) {
      emit(AuthStateError(e.toString()));
    }
  }
}
