import 'package:authentipass/core/error/exceptions.dart';
import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/features/users_management/data/datasource/users_remote_datasource.dart';
import 'package:authentipass/features/users_management/data/models/create_user_model.dart';
import 'package:authentipass/features/users_management/data/models/users_list_model.dart';
import 'package:authentipass/features/users_management/domain/entities/create_user_entity.dart';
import 'package:authentipass/features/users_management/domain/repository/users_repository.dart';
import 'package:dartz/dartz.dart';

class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource remoteDataSource;
  UsersRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<UsersListModel>>> getUsers() async {
    try{
      final users = await remoteDataSource.getUsers();
      return Right(users);
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
  Future<Either<Failure, void>> createUser(CreateUserEntity createUser) async {
    try{
      var createUserModel = CreateUserModel(firstName: createUser.firstName, lastName: createUser.lastName, gender: createUser.gender, email: createUser.email, countryCode: createUser.countryCode, phoneNumber: createUser.phoneNumber, prefersEmail: createUser.prefersEmail,);
      
      await remoteDataSource.createUser(createUserModel);
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