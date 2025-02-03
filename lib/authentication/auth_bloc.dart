import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.signUp(
          email: event.email,
          password: event.password,
        );
        if (user != null) {
          emit(Authenticated(user: user));
        } else {
          emit(AuthError(message: "Signup failed"));
        }
      } catch (e) {
        emit(AuthError(message: e.toString())); // Display error message
      }
    });

    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.signIn(
          email: event.email,
          password: event.password,
        );
        if (user != null) {
          emit(Authenticated(user: user));
        } else {
          emit(AuthError(message: "Login failed"));
        }
      } catch (e) {
        emit(AuthError(message: e.toString())); // Display error message
      }
    });

    on<SignOutRequested>((event, emit) async {
      await authRepository.signOut();
      emit(Unauthenticated());
    });
  }
}
