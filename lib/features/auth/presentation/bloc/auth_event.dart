import 'package:authentipass/features/auth/data/models/auth_user_code_model.dart';
import 'package:authentipass/features/auth/data/models/forgot_password_model.dart';
import 'package:authentipass/features/auth/domain/entity/login_entity.dart';
import 'package:authentipass/features/auth/domain/entity/refresh_token_entity.dart';
import 'package:authentipass/features/auth/domain/entity/register_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable{
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent{}

class AuthLoginRequested extends AuthEvent{
  final LoginEntity login;

  const AuthLoginRequested({required this.login});

  @override
  List<Object?> get props => [login];
}

class AuthRegisterRequested extends AuthEvent{
  final RegisterEntity register;

  const AuthRegisterRequested({required this.register});

  @override
  List<Object?> get props => [register];
}

class AuthRefreshTokenRequested extends AuthEvent{
  final RefreshTokenEntity refreshToken;

  const AuthRefreshTokenRequested({required this.refreshToken});

  @override
  List<Object?> get props => [refreshToken];
}

class AuthLogoutRequested extends AuthEvent{}

class AuthUpdateDeactivationStatus extends AuthEvent {}

class AuthConfirmEmailRequested extends AuthEvent{
  final AuthUserCodeModel codeModel;

  const AuthConfirmEmailRequested({required this.codeModel});

  @override
  List<Object?> get props => [codeModel];
}

class AuthConfirmPhoneRequested extends AuthEvent{
  final AuthUserCodeModel codeModel;

  const AuthConfirmPhoneRequested({required this.codeModel});

  @override
  List<Object?> get props => [codeModel];
}

class AuthResendOtpRequested extends AuthEvent{
  final bool isEmail;

  const AuthResendOtpRequested({required this.isEmail});

  @override
  List<Object?> get props => [isEmail];
}

class AuthForgotPasswordRequested extends AuthEvent{
  final String username;
  final String comType;

  const AuthForgotPasswordRequested({required this.username, required this.comType});

  @override
  List<Object?> get props => [username, comType];
}

class AuthConfirmForgotPasswordRequested extends AuthEvent{
  final ForgotPasswordModel forgotPassword;

  const AuthConfirmForgotPasswordRequested({required this.forgotPassword});

  @override
  List<Object?> get props => [forgotPassword];
}

class AuthBiometricLoginRequested extends AuthEvent {}
class AuthCheckBiometricAvailabilityRequested extends AuthEvent {}