// features/profile/data/repository/profile_repository_impl.dart
import 'dart:io';

import 'package:authentipass/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:authentipass/features/auth/data/models/auth_results_model.dart';
import 'package:authentipass/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:authentipass/features/profile/data/models/change_password_model.dart';
import 'package:authentipass/features/profile/data/models/create_profile_model.dart';
import 'package:authentipass/features/profile/data/models/deactivate_account_model.dart';
import 'package:authentipass/features/profile/data/models/update_email_model.dart';
import 'package:authentipass/features/profile/data/models/update_phone_number_model.dart';
import 'package:authentipass/features/profile/data/models/update_profile_model.dart';
import 'package:authentipass/features/profile/data/models/user_profile_model.dart';
import 'package:authentipass/features/profile/data/models/verify_code_model_dto.dart';
import 'package:authentipass/features/profile/domain/repository/profile_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AuthResultsModel>> createProfile(CreateProfileModel profile) async {
    try {
      final authResults = await remoteDataSource.createProfile(profile);

      // CRITICAL: Cache the new tokens returned after profile creation
      if (authResults.token != null) {
        await localDataSource.cacheToken(authResults.token!);
      }
      if (authResults.refreshToken != null) {
        await localDataSource.cacheRefreshToken(authResults.refreshToken!);
      }

      return Right(authResults);
    } on InvalidRequestException catch (e) {
      return Left(InvalidRequestFailure(e.message ?? "Invalid request"));
    } on InvalidCredentialsExceptions catch (e) {
      return Left(
        InvalidCredentialsFailure(
          e.message ?? "Invalid credentials or unauthorized",
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? "Server error"));
    }
  }

  @override
  Future<Either<Failure, UserProfileModel>> getProfile() async {
    try {
      final profile = await remoteDataSource.getProfile();
      return Right(profile);
    } on InvalidRequestException catch (e) {
      return Left(InvalidRequestFailure(e.message ?? "Invalid request"));
    } on InvalidCredentialsExceptions catch (e) {
      return Left(
        InvalidCredentialsFailure(
          e.message ?? "Invalid credentials or unauthorized",
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? "Server error"));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(UpdateProfileModel update) async {
    try {
      await remoteDataSource.updateProfile(update);
      return Right(null);
    } on InvalidRequestException catch (e) {
      return Left(InvalidRequestFailure(e.message ?? "Invalid request"));
    } on InvalidCredentialsExceptions catch (e) {
      return Left(
        InvalidCredentialsFailure(
          e.message ?? "Invalid credentials or unauthorized",
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? "Server error"));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfilePicture(File? profilePicture) async {
    try {
      await remoteDataSource.updateProfilePicture(profilePicture);
      return Right(null);
    } on InvalidRequestException catch (e) {
      return Left(InvalidRequestFailure(e.message ?? "Invalid request"));
    } on InvalidCredentialsExceptions catch (e) {
      return Left(
        InvalidCredentialsFailure(
          e.message ?? "Invalid credentials or unauthorized",
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? "Server error"));
    }
  }

  @override
  Future<Either<Failure, AuthResultsModel>> activateProfile(DeactivateAccountModel deactivate) async {
    try {
      final authResults = await remoteDataSource.activateProfile(deactivate);
      await localDataSource.clearToken();
      if (authResults.token != null) {
        await localDataSource.cacheToken(authResults.token!);
      }
      if (authResults.refreshToken != null) {
        await localDataSource.cacheRefreshToken(authResults.refreshToken!);
      }
      return Right(authResults);
    } on InvalidRequestException catch (e) {
      return Left(InvalidRequestFailure(e.message ?? "Invalid request"));
    } on InvalidCredentialsExceptions catch (e) {
      return Left(
        InvalidCredentialsFailure(
          e.message ?? "Invalid credentials or unauthorized",
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? "Server error"));
    }
  }

  @override
  Future<Either<Failure, void>> deactivateProfile(DeactivateAccountModel deactivate) async {
    try {
      await remoteDataSource.deactivateProfile(deactivate);
      return Right(null);
    } on InvalidRequestException catch (e) {
      return Left(InvalidRequestFailure(e.message ?? "Invalid request"));
    } on InvalidCredentialsExceptions catch (e) {
      return Left(
        InvalidCredentialsFailure(
          e.message ?? "Invalid credentials or unauthorized",
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? "Server error"));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(ChangePasswordModel changePassword) async {
    try {
      await remoteDataSource.changePassword(changePassword);
      return Right(null);
    } on InvalidRequestException catch (e) {
      return Left(InvalidRequestFailure(e.message ?? "Invalid request"));
    } on InvalidCredentialsExceptions catch (e) {
      return Left(
        InvalidCredentialsFailure(
          e.message ?? "Invalid credentials or unauthorized",
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? "Server error"));
    }
  }

  @override
  Future<Either<Failure, void>> confirmEmail() async {
    try {
      await remoteDataSource.confirmEmail();
      return Right(null);
    } on InvalidRequestException catch (e) {
      return Left(InvalidRequestFailure(e.message ?? "Invalid request"));
    } on InvalidCredentialsExceptions catch (e) {
      return Left(
        InvalidCredentialsFailure(
          e.message ?? "Invalid credentials or unauthorized",
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? "Server error"));
    }
  }

  @override
  Future<Either<Failure, void>> confirmPhoneNumber() async {
    try {
      await remoteDataSource.confirmPhoneNumber();
      return Right(null);
    } on InvalidRequestException catch (e) {
      return Left(InvalidRequestFailure(e.message ?? "Invalid request"));
    } on InvalidCredentialsExceptions catch (e) {
      return Left(
        InvalidCredentialsFailure(
          e.message ?? "Invalid credentials or unauthorized",
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? "Server error"));
    }
  }

  @override
  Future<Either<Failure, void>> setPreferredContactMode(String mode) async {
    try {
      await remoteDataSource.setPreferredContactMode(mode);
      return Right(null);
    } on InvalidRequestException catch (e) {
      return Left(InvalidRequestFailure(e.message ?? "Invalid request"));
    } on InvalidCredentialsExceptions catch (e) {
      return Left(
        InvalidCredentialsFailure(
          e.message ?? "Invalid credentials or unauthorized",
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? "Server error"));
    }
  }

  @override
  Future<Either<Failure, void>> updateEmail(UpdateEmailModel updateEmail) async {
    try {
      await remoteDataSource.updateEmail(updateEmail);
      return Right(null);
    } on InvalidRequestException catch (e) {
      return Left(InvalidRequestFailure(e.message ?? "Invalid request"));
    } on InvalidCredentialsExceptions catch (e) {
      return Left(
        InvalidCredentialsFailure(
          e.message ?? "Invalid credentials or unauthorized",
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? "Server error"));
    }
  }

  @override
  Future<Either<Failure, void>> updatePhoneNumber(UpdatePhoneNumberModel updatePhoneNumber) async {
    try {
      await remoteDataSource.updatePhoneNumber(updatePhoneNumber);
      return Right(null);
    } on InvalidRequestException catch (e) {
      return Left(InvalidRequestFailure(e.message ?? "Invalid request"));
    } on InvalidCredentialsExceptions catch (e) {
      return Left(
        InvalidCredentialsFailure(
          e.message ?? "Invalid credentials or unauthorized",
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? "Server error"));
    }
  }

  @override
  Future<Either<Failure, void>> verifyContactCode(VerifyCodeModelDto verifyCode) async {
    try {
      await remoteDataSource.verifyContactCode(verifyCode);
      return Right(null);
    } on InvalidRequestException catch (e) {
      return Left(InvalidRequestFailure(e.message ?? "Invalid request"));
    } on InvalidCredentialsExceptions catch (e) {
      return Left(
        InvalidCredentialsFailure(
          e.message ?? "Invalid credentials or unauthorized",
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? "Server error"));
    }
  }
}