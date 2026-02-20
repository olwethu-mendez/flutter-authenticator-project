import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/auth/data/models/auth_user_code_model.dart';
import 'package:authentipass/features/auth/domain/entity/auth_results_entity.dart';
import 'package:authentipass/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class ConfirmEmailUsecase implements UseCases<AuthResultsEntity, AuthUserCodeParams>{
  final AuthRepository repository;

  ConfirmEmailUsecase({required this.repository});

  @override
  Future<Either<Failure,AuthResultsEntity>> call(AuthUserCodeParams params) async {
    return await repository.confirmEmail(params.codeModel);
  }
}

class AuthUserCodeParams extends Equatable{
  final AuthUserCodeModel codeModel;

  const AuthUserCodeParams({required this.codeModel});

  @override
  List<Object> get props => [codeModel];
}