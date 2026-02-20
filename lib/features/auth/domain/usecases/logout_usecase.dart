import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

class LogoutUseCase implements UseCases<void, NoParams>{
  final AuthRepository repository;

  LogoutUseCase({required this.repository});

  @override
  Future<Either<Failure,void>> call(NoParams params) async {
    return await repository.logout();
  }
}