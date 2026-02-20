import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/users_management_list_view/domain/repository/users_view_repository.dart';
import 'package:dartz/dartz.dart';

class GetViewUsecase implements UseCases<bool?, NoParams> {
  final UsersViewRepository repository;
  GetViewUsecase(this.repository);

  @override
  Future<Either<Failure, bool?>> call(NoParams params) async {
    return await repository.getListView();
  }  
}