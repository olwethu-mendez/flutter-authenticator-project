import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/auth/domain/entity/auth_results_entity.dart';
import 'package:authentipass/features/auth/domain/repository/auth_repository.dart';
import 'package:authentipass/features/auth/domain/usecases/confirm_email_usecase.dart';
import 'package:dartz/dartz.dart';

class ConfirmPhoneUsecase implements UseCases<AuthResultsEntity, AuthUserCodeParams>{
  final AuthRepository repository;

  ConfirmPhoneUsecase({required this.repository});

  @override
  Future<Either<Failure,AuthResultsEntity>> call(AuthUserCodeParams params) async {
    return await repository.confirmPhonenumber(params.codeModel);
  }
}