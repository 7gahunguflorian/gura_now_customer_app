import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/secure_storage.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_me_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetMeUseCase getMeUseCase,
    required SecureStorageService storage,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _getMeUseCase = getMeUseCase,
        _storage = storage,
        super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSkipLoginRequested>(_onSkipLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSetUnauthenticatedRequested>(_onSetUnauthenticatedRequested);
  }

  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetMeUseCase _getMeUseCase;
  final SecureStorageService _storage;

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final token = await _storage.getToken();
      if (token == null) {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
        return;
      }
      final result = await _getMeUseCase(NoParams());
      result.fold(
        (failure) {
          add(const AuthLogoutRequested());
        },
        (user) => emit(state.copyWith(
              status: AuthStatus.authenticated,
              user: user,
            )),
      );
    } catch (_) {
      add(const AuthLogoutRequested());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _loginUseCase(LoginParams(
      phoneNumber: event.phoneNumber,
      password: event.password,
    ));
    result.fold(
      (failure) => emit(state.copyWith(
            status: AuthStatus.error,
            errorMessage: failure.message,
          )),
      (user) => emit(state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          )),
    );
  }

  Future<void> _onSkipLoginRequested(
    AuthSkipLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _loginUseCase(const LoginParams(
      phoneNumber: '+250788123456',
      password: 'demo',
    ));
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      )),
      (user) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      )),
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _registerUseCase(RegisterParams(
      fullName: event.fullName,
      phoneNumber: event.phoneNumber,
      password: event.password,
      role: event.role,
      email: event.email,
    ));
    result.fold(
      (failure) => emit(state.copyWith(
            status: AuthStatus.error,
            errorMessage: failure.message,
          )),
      (user) => emit(state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          )),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await _logoutUseCase(NoParams());
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
    ));
  }

  void _onSetUnauthenticatedRequested(
    AuthSetUnauthenticatedRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
  }
}
