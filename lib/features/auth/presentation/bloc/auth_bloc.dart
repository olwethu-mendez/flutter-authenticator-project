import 'dart:async';
import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/services/signalr_service.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:authentipass/features/auth/domain/entity/login_entity.dart';
import 'package:authentipass/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:authentipass/features/auth/domain/usecases/confirm_email_usecase.dart';
import 'package:authentipass/features/auth/domain/usecases/confirm_forgot_password_usecase.dart';
import 'package:authentipass/features/auth/domain/usecases/confirm_phone_usecase.dart';
import 'package:authentipass/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:authentipass/features/auth/domain/usecases/login_usecase.dart';
import 'package:authentipass/features/auth/domain/usecases/logout_usecase.dart';
import 'package:authentipass/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:authentipass/features/auth/domain/usecases/register_usecase.dart';
import 'package:authentipass/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_event.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_state.dart';
import 'package:authentipass/features/settings/data/datasource/settings_local_datasource.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckAuthUseCase checkAuthUseCase;
  final LoginUseCases loginUseCase;
  final LogoutUseCase logoutUseCase;
  final RefreshTokenUseCases refreshTokenUseCase;
  final RegisterUseCases registerUseCase;
  final ConfirmEmailUsecase confirmEmailUsecase;
  final ConfirmPhoneUsecase confirmPhoneUsecase;
  final ResendOtpUsecase resendOtpUsecase;
  final ForgotPasswordUsecase forgotPasswordUsecase;
  final ConfirmForgotPasswordUsecase confirmForgotPasswordUsecase;

  final AuthLocalDataSource authLocalDataSource;
  final SettingsLocalDatasource settingsLocalDataSource;

  final SignalRService _signalRService;
  StreamSubscription? _signalRSubscription;

  AuthBloc({
    required this.checkAuthUseCase,
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.refreshTokenUseCase,
    required this.registerUseCase,
    required this.confirmEmailUsecase,
    required this.confirmPhoneUsecase,
    required this.resendOtpUsecase,
    required this.forgotPasswordUsecase,
    required this.confirmForgotPasswordUsecase,

    required this.authLocalDataSource,
    required this.settingsLocalDataSource,

    required SignalRService signalRService,
  }) : _signalRService = signalRService,
       super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthConfirmEmailRequested>(_onAuthConfirmEmailRequested);
    on<AuthConfirmPhoneRequested>(_onAuthConfirmPhoneRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthResendOtpRequested>(_onAuthResendOtpRequested);
    on<AuthForgotPasswordRequested>(_onAuthForgotPasswordRequested);
    on<AuthConfirmForgotPasswordRequested>(
      _onAuthConfirmForgotPasswordRequested,
    );
    on<AuthUpdateDeactivationStatus>(_onAuthUpdateDeactivationStatus);
    on<AuthCheckBiometricAvailabilityRequested>(
      _onAuthCheckBiometricAvailabilityRequested,
    );
    on<AuthBiometricLoginRequested>(_onAuthBiometricLoginRequested);

    // Listen to SignalR events
    // features/auth/presentation/bloc/auth_bloc.dart

    _signalRSubscription = _signalRService.statusStream.listen((message) {
      final currentState = state;
      if (currentState is AuthAuthenticated) {
        // If the ID coming from SignalR matches the currently logged in user
        if (message.userId == currentState.userId && message.isDeactivated) {
          add(
            AuthLogoutRequested(),
          ); // Or a custom event to show the BannedPage
        }
      }
    });
  }

  String _preferredType(String input) {
    // Use the combined regular expression pattern
    final emailPatterm = RegExp(
      r'^([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})$',
    );
    final phonePattern = RegExp(r'^(\d{9})$');

    // Check if the input matches the pattern
    return emailPatterm.hasMatch(input)
        ? "email"
        : phonePattern.hasMatch(input)
        ? "phone"
        : "invalid";
  }

  AuthAuthenticated _buildAuthenticatedState(String token) {
    final decoded = JwtDecoder.decode(token);

    bool parseBool(dynamic value) => value.toString().toLowerCase() == 'true';

    return AuthAuthenticated(
      token: token,
      userId:
          decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
          decoded['sub'] ??
          "",
      username:
          decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'],
      email: decoded['email'] ?? "",
      role:
          decoded['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ??
          "General",
      isActivated: parseBool(decoded['IsActivated']),
      hasProfile: parseBool(decoded['HasProfile']),
      isDeactivated: parseBool(decoded['IsDeactivated']),
      isDeactivatedByAdmin: parseBool(decoded['IsDeactivatedByAdmin']),
      emailConfirmed: parseBool(decoded['EmailConfirmed']),
      phoneConfirmed: parseBool(decoded['PhoneConfirmed']),
      preferredCommunication: _preferredType(
        decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'],
      ),
    );
  }

  AuthForgotPasswordOtp _buildForgotPasswordState({
    required String username,
    required String comType,
  }) {
    return AuthForgotPasswordOtp(username: username, comType: comType);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // 1. Check if we even have a token stored locally first
    final token = await authLocalDataSource.getCachedToken();

    if (token == null) {
      emit(AuthUnauthenticated());
      return;
    }

    // 2. We have a token! Now ask the server if it's still valid
    final result = await checkAuthUseCase(NoParams());
    result.fold((failure) => emit(AuthUnauthenticated()), (isAuthenticated) {
      if (isAuthenticated) {
        _signalRService.initHub(); // 👈 ADD THIS
        emit(_buildAuthenticatedState(token));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginUseCase(LoginParams(loginEntity: event.login));

    await result.fold((failure) async => emit(_mapFailureToState(failure)), (
      authResult,
    ) async {
      // CRUCIAL: Save credentials so Biometrics work next time!
      await authLocalDataSource.cacheBiometricCredentials(
        event.login.username ?? "",
        event.login.password ?? "",
        event.login.countryCode,
      );
      _signalRService.initHub(); // 👈 ADD THIS
      emit(_buildAuthenticatedState(authResult.token!));
    });
  }

  Future<void> _onAuthCheckBiometricAvailabilityRequested(
    AuthCheckBiometricAvailabilityRequested event,
    Emitter<AuthState> emit,
  ) async {
    final hasAccount = await authLocalDataSource.hasBiometricCredentials();
    final isEnabledInSettings = await settingsLocalDataSource
        .getBiometricAuthSettings();
    emit(
      BiometricAvailabilityChecked(
        hasAccount && (isEnabledInSettings ?? false),
      ),
    );
  }

  Future<void> _onAuthBiometricLoginRequested(
    AuthBiometricLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // A. Fetch credentials from our secure source
      final creds = await authLocalDataSource.getBiometricCredentials();

      if (creds['username'] == null || creds['password'] == null) {
        emit(
          AuthError(
            message:
                "No biometric credentials saved. Please login manually first.",
          ),
        );
        return;
      }

      // B. Trigger the existing Login UseCase
      final loginEntity = LoginEntity(
        username: creds['username']!,
        password: creds['password']!,
        countryCode: creds['countryCode'],
        stayLoggedIn: true,
      );

      final result = await loginUseCase(LoginParams(loginEntity: loginEntity));

      result.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (authResult) {
          _signalRService.initHub(); // 👈 ADD THIS
           emit(_buildAuthenticatedState(authResult.token!));
        },
      );
    } catch (e) {
      emit(AuthError(message: "Biometric login failed: $e"));
    }
  }

  Future<void> _onAuthConfirmEmailRequested(
    AuthConfirmEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await confirmEmailUsecase(
      AuthUserCodeParams(codeModel: event.codeModel),
    );

    result.fold(
      (failure) => emit(_mapFailureToState(failure)),
      (authResult) => emit(_buildAuthenticatedState(authResult.token!)),
    );
  }

  Future<void> _onAuthConfirmPhoneRequested(
    AuthConfirmPhoneRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await confirmPhoneUsecase(
      AuthUserCodeParams(codeModel: event.codeModel),
    );

    result.fold(
      (failure) => emit(_mapFailureToState(failure)),
      (authResult) => emit(_buildAuthenticatedState(authResult.token!)),
    );
  }

  Future<void> _onAuthResendOtpRequested(
    AuthResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await resendOtpUsecase(event.isEmail);
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => null,
    );
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await registerUseCase(
      RegisterParams(registerEntity: event.register),
    );

    await result.fold((failure) async => emit(_mapFailureToState(failure)), (
      authResult,
    ) async {
      await authLocalDataSource.cacheBiometricCredentials(
        event.register.prefersEmail == true
            ? event.register.email ?? ""
            : event.register.phoneNumber ?? "",
        event.register.password ?? "",
        event.register.countryCode,
      );
      _signalRService.initHub(); // 👈 ADD THIS
      emit(_buildAuthenticatedState(authResult.token!));
    });
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    //emit(AuthLoading());

    final result = await logoutUseCase(NoParams());

    result.fold(
      (failure) => emit(
        AuthError(message: failure.message),
      ), // Or just force Unauthenticated
      (_) => emit(AuthUnauthenticated(message: event.message)),
    );
  }

  // Helper to clean up error messages
  AuthState _mapFailureToState(Failure failure) {
    // Instead of hardcoding "Invalid data provided", use the message from the API!
    return AuthError(message: failure.message);
  }

  Future<void> _onAuthForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await forgotPasswordUsecase(event.username);

    result.fold((failure) => emit(AuthError(message: failure.message)), (_) {
      emit(
        _buildForgotPasswordState(
          username: event.username,
          comType: event.comType,
        ),
      );
    });
  }

  Future<void> _onAuthConfirmForgotPasswordRequested(
    AuthConfirmForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await confirmForgotPasswordUsecase(
      ForgotPasswordParams(forgotPassword: event.forgotPassword),
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthPasswordReset()),
    );
  }

  Future<void> _onAuthUpdateDeactivationStatus(
    AuthUpdateDeactivationStatus event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthAuthenticated) {
      final currentState = state as AuthAuthenticated;

      emit(
        AuthAuthenticated(
          token: currentState.token,
          userId: currentState.userId,
          email: currentState.email,
          username: currentState.username,
          role: currentState.role,
          isActivated: currentState.isActivated,
          hasProfile: currentState.hasProfile,
          isDeactivated: true,
          isDeactivatedByAdmin: currentState.isDeactivatedByAdmin,
          emailConfirmed: currentState.emailConfirmed,
          phoneConfirmed: currentState.phoneConfirmed,
          preferredCommunication: currentState.preferredCommunication,
        ),
      );
    }
  }
}
