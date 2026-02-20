import 'package:authentipass/core/error/exceptions.dart';
import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/features/user_details/data/datasource/user_details_remote_datasource.dart';
import 'package:authentipass/features/user_details/domain/entities/get_user_entity.dart';
import 'package:authentipass/features/user_details/domain/repository/user_details_repository.dart';
import 'package:dartz/dartz.dart';

class UserDetailsRepositoryImpl implements UserDetailsRepository {
  final UserDetailsRemoteDataSource remoteDataSource;
  UserDetailsRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, String>> adminDeactivatesUser(String userId) async {
    try{
      final deactivated = await remoteDataSource.adminDeactivatesUser(userId);
      return Right(deactivated);
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
  Future<Either<Failure, GetUserEntity>> getSingleUser(String userId) async {
    try{
      final singleUser = await remoteDataSource.getSingleUser(userId);
      return Right(singleUser);
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