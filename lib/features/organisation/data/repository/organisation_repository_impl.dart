import 'package:authentipass/core/error/exceptions.dart';
import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:authentipass/features/auth/data/models/auth_results_model.dart';
import 'package:authentipass/features/organisation/data/datasource/organisation_remote_datasource.dart';
import 'package:authentipass/features/organisation/data/models/create_organisation_model.dart';
import 'package:authentipass/features/organisation/data/models/get_my_organisation_model.dart';
import 'package:authentipass/features/organisation/data/models/get_organisation_model.dart';
import 'package:authentipass/features/organisation/data/models/get_organisations_model.dart';
import 'package:authentipass/features/organisation/domain/repository/organisation_repository.dart';
import 'package:dartz/dartz.dart';

class OrganisationRepositoryImpl implements OrganisationRepository {  
  final OrganisationRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  OrganisationRepositoryImpl({required this.remoteDataSource, required this.localDataSource});

  @override
  Future<Either<Failure, List<GetMyOrganisationModel>>> getMyOrganisations() async {
    try {
      final myOrganisations = await remoteDataSource.getMyOrganisations();
      return Right(myOrganisations);
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
  Future<Either<Failure, GetOrganisationModel>> getOrganisation(String organisationId) async {
    try {
      final organisation = await remoteDataSource.getOrganisation(organisationId);
      return Right(organisation);
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
  Future<Either<Failure, List<GetOrganisationsModel>>> getPublicOrganisations() async {
    try {
      final publicOrganisation = await remoteDataSource.getPublicOrganisations();
      return Right(publicOrganisation);
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
  Future<Either<Failure, AuthResultsModel>> switchOrganisation(String organisationId) async {
    try {
      final authResults = await remoteDataSource.switchOrganisation(organisationId);
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
  Future<Either<Failure, AuthResultsModel>> acceptInvitation(String organisationId, bool invitationAccepted) async {
    try {
      final authResults = await remoteDataSource.acceptInvitation(organisationId, invitationAccepted);
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
  Future<Either<Failure, AuthResultsModel>> createOrganisation(CreateOrganisationModel createOrganisation) async {
    try {
      final authResults = await remoteDataSource.createOrganisation(createOrganisation);
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
  Future<Either<Failure, void>> inviteUserToOrganisation(String profileId) async {
    try {
      await remoteDataSource.inviteUserToOrganisation(profileId);
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