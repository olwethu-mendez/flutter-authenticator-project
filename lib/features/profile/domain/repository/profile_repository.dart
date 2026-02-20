// features/profile/domain/repository/profile_repository.dart
import 'dart:io';

import 'package:authentipass/features/auth/data/models/auth_results_model.dart';
import 'package:authentipass/features/profile/data/models/change_password_model.dart';
import 'package:authentipass/features/profile/data/models/deactivate_account_model.dart';
import 'package:authentipass/features/profile/data/models/update_email_model.dart';
import 'package:authentipass/features/profile/data/models/update_phone_number_model.dart';
import 'package:authentipass/features/profile/data/models/update_profile_model.dart';
import 'package:authentipass/features/profile/data/models/user_profile_model.dart';
import 'package:authentipass/features/profile/data/models/verify_code_model_dto.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/create_profile_model.dart';

abstract class ProfileRepository {
  Future<Either<Failure, AuthResultsModel>> createProfile(CreateProfileModel profile);
  Future<Either<Failure, UserProfileModel>> getProfile();
  Future<Either<Failure, void>> updateProfile(UpdateProfileModel update);
  Future<Either<Failure, void>> updateProfilePicture(File? profilePicture); 
  Future<Either<Failure, AuthResultsModel>> activateProfile(DeactivateAccountModel deactivate);
  Future<Either<Failure, void>> deactivateProfile(DeactivateAccountModel deactivate);

  Future<Either<Failure, void>> setPreferredContactMode(String mode);
  Future<Either<Failure, void>> verifyContactCode(VerifyCodeModelDto verifyCode);
  Future<Either<Failure, void>> changePassword(ChangePasswordModel changePassword);
  Future<Either<Failure, void>> updateEmail(UpdateEmailModel updateEmail);
  Future<Either<Failure, void>> updatePhoneNumber(UpdatePhoneNumberModel updatePhoneNumber);
  Future<Either<Failure, void>> confirmPhoneNumber();
  Future<Either<Failure, void>> confirmEmail();
}