import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/users_management_list_view/domain/repository/users_view_repository.dart';
import 'package:dartz/dartz.dart';

class SetViewUsecase implements UseCases<void, bool> {
  final UsersViewRepository repository;
  SetViewUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(bool isGrid) async {
    return await repository.setListView(isGrid);
  }  
}