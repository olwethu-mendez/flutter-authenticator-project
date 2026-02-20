// features/profile/presentation/bloc/profile_event.dart
import 'dart:io';

import 'package:authentipass/features/profile/data/models/change_password_model.dart';
import 'package:authentipass/features/profile/data/models/create_profile_model.dart';
import 'package:authentipass/features/profile/data/models/deactivate_account_model.dart';
import 'package:authentipass/features/profile/data/models/update_email_model.dart';
import 'package:authentipass/features/profile/data/models/update_phone_number_model.dart';
import 'package:authentipass/features/profile/data/models/update_profile_model.dart';
import 'package:authentipass/features/profile/data/models/verify_code_model_dto.dart';
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class CreateProfileRequested extends ProfileEvent {
  final CreateProfileModel createProfileModel;

  const CreateProfileRequested({required this.createProfileModel});

  @override
  List<Object?> get props => [createProfileModel];
}

class UpdateProfileRequested extends ProfileEvent {
  final UpdateProfileModel? upateProfileModel;

  const UpdateProfileRequested({
    this.upateProfileModel,
  });

  @override
  List<Object?> get props => [
    upateProfileModel
  ];
}

class UpdateEmailRequested extends ProfileEvent {
  final UpdateEmailModel? updateEmailModel;
  const UpdateEmailRequested({
    this.updateEmailModel,
  });

  @override
  List<Object?> get props => [
    updateEmailModel,
  ];
}

class UpdatePhoneNumberRequested extends ProfileEvent {
  final UpdatePhoneNumberModel? updatePhoneNumberModel;

  const UpdatePhoneNumberRequested({
    this.updatePhoneNumberModel,
  });

  @override
  List<Object?> get props => [
    updatePhoneNumberModel,
  ];
}

class ChangePasswordRequested extends ProfileEvent {
  final ChangePasswordModel changePasswordModel;

  const ChangePasswordRequested({required this.changePasswordModel});

  @override
  List<Object?> get props => [changePasswordModel];
}

class VerifyCodeRequested extends ProfileEvent {
  final VerifyCodeModelDto code;

  const VerifyCodeRequested({required this.code});

  @override
  List<Object?> get props => [code];
}

class SetPreferredContactModeRequested extends ProfileEvent {
  final String mode;

  const SetPreferredContactModeRequested({required this.mode});

  @override
  List<Object?> get props => [mode];
}

class ConfirmEmailRequested extends ProfileEvent {}

class ConfirmPhoneNumberRequested extends ProfileEvent {}



class UpdateProfilePictureRequested extends ProfileEvent {
  final File? profilePicture;

  const UpdateProfilePictureRequested({required this.profilePicture});

  @override
  List<Object?> get props => [profilePicture];
}

class ActivateProfileRequested extends ProfileEvent {
  final DeactivateAccountModel deactivate;

  const ActivateProfileRequested({required this.deactivate});

  @override
  List<Object?> get props => [deactivate];
}

class DeactivateProfileRequested extends ProfileEvent {
  final DeactivateAccountModel deactivate;

  const DeactivateProfileRequested({required this.deactivate});

  @override
  List<Object?> get props => [deactivate];
}

class FetchProfileRequested extends ProfileEvent {}

class BiometricDeactivateRequested extends ProfileEvent {}

class ProfileCheckBiometricAvailabilityRequested extends ProfileEvent {}

class ResetProfileFlagsEvent extends ProfileEvent {}