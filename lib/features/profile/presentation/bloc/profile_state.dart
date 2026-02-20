// features/profile/presentation/bloc/profile_state.dart
import 'package:authentipass/features/auth/data/models/auth_results_model.dart';
import 'package:authentipass/features/profile/data/models/user_profile_model.dart';
import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileCreated extends ProfileState {
  final AuthResultsModel authResults;
  const ProfileCreated(this.authResults);
}

class ProfileUpdated extends ProfileState {
  final bool emailChanged;
  final bool phoneChanged;
  final bool preferredContactModeChanged;
  final bool passwordChanged;
  final bool emailConfirmed;
  final bool phoneConfirmed;
  final bool profilePictureChanged;
  final bool profileInfoChanged;
  final bool verifiedCode;
  const ProfileUpdated({
    this.emailChanged = false,
    this.phoneChanged = false,
    this.preferredContactModeChanged = false,
    this.passwordChanged = false,
    this.emailConfirmed = false,
    this.phoneConfirmed = false,
    this.profilePictureChanged = false,
    this.profileInfoChanged = false,
    this.verifiedCode = false,
  });
}

class ProfilePictureUpdated extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
}

// features/profile/presentation/bloc/profile_state.dart
class ProfileLoaded extends ProfileState {
  final UserProfileModel profile;
  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileDeactivated extends ProfileState {}

class ProfileActivated extends ProfileState {
  final AuthResultsModel authResults;
  const ProfileActivated(this.authResults);
}

class BiometricAvailabilityChecked extends ProfileState {
  final bool isAvailable;
  const BiometricAvailabilityChecked(this.isAvailable);
}
