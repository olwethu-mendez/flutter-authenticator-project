import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/users_management/domain/entities/users_list_entity.dart';
import 'package:authentipass/features/users_management/domain/repository/users_repository.dart';
import 'package:dartz/dartz.dart';

class GetUsersUsecase implements UseCases<List<UsersListEntity>, NoParams> {
  final UsersRepository repository;
  GetUsersUsecase(this.repository);

  @override
  Future<Either<Failure, List<UsersListEntity>>> call(NoParams params) async {
    return await repository.getUsers();
  }  
}