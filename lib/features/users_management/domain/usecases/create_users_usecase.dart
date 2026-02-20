// features/User/domain/usecases/create_User_usecase.dart
import 'package:authentipass/features/users_management/data/models/create_user_model.dart';
import 'package:authentipass/features/users_management/domain/repository/users_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class CreateUserUseCase implements UseCases<void, CreateUserModel> {
  final UsersRepository repository;
  CreateUserUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateUserModel params) async {
    return await repository.createUser(params);
  }
}