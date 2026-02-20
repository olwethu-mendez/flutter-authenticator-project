import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

class ForgotPasswordUsecase implements UseCases<void, String>{
  final AuthRepository repository;

  ForgotPasswordUsecase({required this.repository});

  @override
  Future<Either<Failure,void>> call(String username) async {
    return await repository.forgotPassword(username);
  }
}