// features/auth/presentation/bloc/auth_state.dart

import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable{
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState{}

class AuthLoading extends AuthState{}

class AuthAuthenticated extends AuthState {
  final String token;
  final String userId; // Add this field
  final String email;
  final String username;
  final String role;
  final bool isActivated;
  final bool hasProfile;
  final bool isDeactivated;
  final bool isDeactivatedByAdmin;
  final bool emailConfirmed;
  final bool phoneConfirmed;
  final String preferredCommunication;

  const AuthAuthenticated({
    required this.token,
    required this.userId, // Add this
    required this.email,
    required this.username,
    required this.role,
    required this.isActivated,
    required this.hasProfile,
    required this.isDeactivated,
    required this.isDeactivatedByAdmin,
    required this.emailConfirmed,
    required this.phoneConfirmed,
    required this.preferredCommunication,
  });

  @override
  List<Object?> get props => [token, userId, email, username, role, isActivated, hasProfile, isDeactivated, isDeactivatedByAdmin, emailConfirmed, phoneConfirmed, preferredCommunication];
}
class AuthProfileCreationRequired extends AuthState {
  // New State: Token exists, but profile is missing
}

class AuthUnauthenticated extends AuthState {
  final String? message;

  const AuthUnauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}

class AuthForgotPasswordOtp extends AuthState{
  final String username;
  final String comType; // 'email' or 'phone'

  const AuthForgotPasswordOtp({
    required this.username,
    required this.comType,
  });

  @override
  List<Object?> get props => [username, comType];
}
class AuthPasswordReset extends AuthState{}

class BiometricAvailabilityChecked extends AuthState {
  final bool isAvailable;
  const BiometricAvailabilityChecked(this.isAvailable);
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message}); 

  @override
  List<Object?> get props => [message];
}