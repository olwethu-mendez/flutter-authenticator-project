// features/profile/presentation/bloc/profile_bloc.dart
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:authentipass/features/profile/domain/usecases/confirm_email_usecase.dart';
import 'package:authentipass/features/profile/data/models/deactivate_account_model.dart';
import 'package:authentipass/features/profile/domain/usecases/activate_profile_usecase.dart';
import 'package:authentipass/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:authentipass/features/profile/domain/usecases/confirm_phone_number_usecase.dart';
import 'package:authentipass/features/profile/domain/usecases/deactivate_profile_usecase.dart';
import 'package:authentipass/features/profile/domain/usecases/create_profile_usecase.dart';
import 'package:authentipass/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:authentipass/features/profile/domain/usecases/set_preferred_contact_mode_usecase.dart';
import 'package:authentipass/features/profile/domain/usecases/update_email_usecase.dart';
import 'package:authentipass/features/profile/domain/usecases/update_phone_number_usecase.dart';
import 'package:authentipass/features/profile/domain/usecases/update_profile_picture_usecase.dart';
import 'package:authentipass/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:authentipass/features/profile/domain/usecases/verify_code_usecase.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_event.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_state.dart';
import 'package:authentipass/features/settings/data/datasource/settings_local_datasource.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final CreateProfileUseCase createProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ActivateProfileUseCase activateProfileUseCase;
  final DeactivateProfileUseCase deactivateProfileUseCase;
  final UpdateProfilePictureUseCase updateProfilePictureUseCase;
  final GetProfileUseCase getProfileUseCase;

  final UpdateEmailUseCase updateEmailUseCase;
  final UpdatePhoneNumberUsecase updatePhoneNumberUsecase;
  final VerifyCodeUsecase verifyCodeUsecase;
  final ChangePasswordUsecase changePasswordUsecase;
  final SetPreferredContactModeUsecase setPreferredContactModeUsecase;
  final ConfirmEmailUsecase confirmEmailUsecase;
  final ConfirmPhoneNumberUsecase confirmPhoneNumberUsecase;

  final AuthLocalDataSource authLocalDataSource;
  final SettingsLocalDatasource settingsLocalDataSource;

  ProfileBloc({
    required this.createProfileUseCase,
    required this.getProfileUseCase,
    required this.updateProfilePictureUseCase,
    required this.updateProfileUseCase,
    required this.activateProfileUseCase,
    required this.deactivateProfileUseCase,

    required this.updateEmailUseCase,
    required this.updatePhoneNumberUsecase,
    required this.verifyCodeUsecase,
    required this.changePasswordUsecase,
    required this.setPreferredContactModeUsecase,
    required this.confirmEmailUsecase,
    required this.confirmPhoneNumberUsecase,

    required this.authLocalDataSource,
    required this.settingsLocalDataSource,
    }) : super(ProfileInitial()) {

    on<ActivateProfileRequested>((event, emit) async {
      emit(ProfileLoading());
      final result = await activateProfileUseCase(event.deactivate);
      result.fold(
        (failure) => emit(ProfileError(failure.message)),
        (success) => emit(ProfileActivated(success)),
      );
    });

    on<UpdateProfileRequested>((event, emit) async {
      emit(ProfileLoading());
      final result = await updateProfileUseCase(event.upateProfileModel!);
      result.fold(
        (failure) => emit(ProfileError(failure.message)),
        (success) => emit(ProfileUpdated(profileInfoChanged: true)),
      );
    });

    on<UpdateProfilePictureRequested>((event, emit) async {
      emit(ProfileLoading());
      final result = await updateProfilePictureUseCase(event.profilePicture);
      result.fold(
        (failure) => emit(ProfileError(failure.message)),
        (success) => emit(ProfilePictureUpdated()),
      );
    });

    on<CreateProfileRequested>((event, emit) async {
      emit(ProfileLoading());
      final result = await createProfileUseCase(event.createProfileModel);
      result.fold(
        (failure) => emit(ProfileError(failure.message)),
        (authResults) => emit(ProfileCreated(authResults)),
      );
    });
    
    on<FetchProfileRequested>((event, emit) async {
      emit(ProfileLoading());
      final result = await getProfileUseCase(NoParams());
      result.fold(
        (failure) => emit(ProfileError(failure.message)), 
        (profile) => emit(ProfileLoaded(profile)),
      );
    });

    on<DeactivateProfileRequested>((event, emit) async {
      emit(ProfileLoading());
      final result = await deactivateProfileUseCase(event.deactivate);
      result.fold(
        (failure) => emit(ProfileError(failure.message)),
        (success) => emit(ProfileDeactivated()),
      );
    });

    on<ProfileCheckBiometricAvailabilityRequested>((event, emit) async {
      final isAvailable = await authLocalDataSource.hasBiometricCredentials();
      final isEnabledInSettings = await settingsLocalDataSource.getBiometricAuthSettings() ?? false;
      final isAvailableFinal = isAvailable && isEnabledInSettings;
      emit(BiometricAvailabilityChecked(isAvailableFinal));
    });
    
    on<BiometricDeactivateRequested>((event, emit) async {
      emit(ProfileLoading());
      try{
        final creds = await authLocalDataSource.getBiometricCredentials();
        if(creds['password'] != null){
          final deactivateModel = DeactivateAccountModel(
            password: creds['password']!,
          );
          final result = await deactivateProfileUseCase(deactivateModel);
          result.fold(
            (failure) => emit(ProfileError(failure.message)),
            (success) => emit(ProfileDeactivated()),
          );
        } else {
          emit(ProfileError("No biometric credentials found."));
        }
      }
      catch(e){
        emit(ProfileError("Failed to retrieve biometric credentials."));
      }
    });

    on<UpdateEmailRequested>((event, emit) async {
      emit(ProfileLoading());
      final result = await updateEmailUseCase(event.updateEmailModel!);
      result.fold(
        (failure) => emit(ProfileError(failure.message)),
        (success) => emit(ProfileUpdated(emailChanged: true)),
      );
    });

    on<UpdatePhoneNumberRequested>((event, emit) async {
      emit(ProfileLoading());
      final result = await updatePhoneNumberUsecase(event.updatePhoneNumberModel!);
      result.fold(
        (failure) => emit(ProfileError(failure.message)),
        (success) => emit(ProfileUpdated(phoneChanged: true)),
      );
    });

    on<ChangePasswordRequested>((event, emit) async {
      emit(ProfileLoading());
      final result = await changePasswordUsecase(event.changePasswordModel);
      result.fold(
        (failure) => emit(ProfileError(failure.message)),
        (success) => emit(ProfileUpdated(passwordChanged: true)),
      );
    });

    on<SetPreferredContactModeRequested>((event, emit) async {
      emit(ProfileLoading());
      final result = await setPreferredContactModeUsecase(event.mode);
      result.fold(
        (failure) => emit(ProfileError(failure.message)),
        (success) => emit(ProfileUpdated(preferredContactModeChanged: true)),
      );
    });

    on<ConfirmEmailRequested>((event, emit) async {
      emit(ProfileLoading());
      final result = await confirmEmailUsecase(NoParams());
      result.fold(
        (failure) => emit(ProfileError(failure.message)),
        (success) => emit(ProfileUpdated(emailConfirmed: true)),
      );
    });

    on<ConfirmPhoneNumberRequested>((event, emit) async {
      emit(ProfileLoading());
      final result = await confirmPhoneNumberUsecase(NoParams());
      result.fold(
        (failure) => emit(ProfileError(failure.message)),
        (success) => emit(ProfileUpdated(phoneConfirmed: true)),
      );
    });

    on<ResetProfileFlagsEvent>((event, emit) {
      // Reset to initial state without any flags
      emit(ProfileUpdated(
        emailChanged: false,
        phoneChanged: false,
        preferredContactModeChanged: false,
        passwordChanged: false,
        emailConfirmed: false,
        phoneConfirmed: false,
        profilePictureChanged: false,
        profileInfoChanged: false,
        verifiedCode: false,
      ));
    });
  }
}