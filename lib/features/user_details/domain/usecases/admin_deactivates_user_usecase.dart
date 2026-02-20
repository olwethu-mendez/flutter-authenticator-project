import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/user_details/domain/repository/user_details_repository.dart';
import 'package:dartz/dartz.dart';

class AdminDeactivatesUserUsecase implements UseCases<String,String> {
  final UserDetailsRepository repository;
  AdminDeactivatesUserUsecase(this.repository);

  @override
  Future<Either<Failure, String>> call(String param) async {
    return await repository.adminDeactivatesUser(param);
  }
}