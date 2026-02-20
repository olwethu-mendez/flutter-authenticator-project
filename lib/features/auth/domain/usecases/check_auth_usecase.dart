import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

class CheckAuthUseCase implements UseCases<bool, NoParams>{
  final AuthRepository repository;

  CheckAuthUseCase({required this.repository});

  @override
  Future<Either<Failure,bool>> call(NoParams params) async {
    return await repository.isAuthenticated();
  }
}