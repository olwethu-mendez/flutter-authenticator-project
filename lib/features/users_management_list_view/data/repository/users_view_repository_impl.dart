import 'package:authentipass/core/error/exceptions.dart';
import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/features/users_management_list_view/data/datasource/users_view_local_datasource.dart';
import 'package:authentipass/features/users_management_list_view/domain/repository/users_view_repository.dart';
import 'package:dartz/dartz.dart';

class UsersViewRepositoryImpl implements UsersViewRepository {
  final UsersViewLocalDataSource localDataSource;
  UsersViewRepositoryImpl({
    required this.localDataSource,
  });
  
  @override
  Future<Either<Failure, bool?>> getListView() async {
    try{
      final isGrid = await localDataSource.getView();
      return Right(isGrid);
    } on InvalidRequestException catch (e) {
      return Left(InvalidRequestFailure(e.message ?? "Invalid request"));
    } on CacheException{
      return Left(
        CacheFailure(
          "Something went wrong retrieving your view",
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? "Server error"));
    }
  }
  
  @override
  Future<Either<Failure, void>> setListView(bool isGrid) async {
    try{
      await localDataSource.setView(isGrid);
      return Right(null);
    } on InvalidRequestException catch (e) {
      return Left(InvalidRequestFailure(e.message ?? "Invalid request"));
    } on CacheException {
      return Left(
        CacheFailure(
          "Something went wrong setting your view",
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? "Server error"));
    }
  }
  
}