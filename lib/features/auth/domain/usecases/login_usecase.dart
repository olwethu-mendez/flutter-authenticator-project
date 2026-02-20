import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/auth/domain/entity/auth_results_entity.dart';
import 'package:authentipass/features/auth/domain/entity/login_entity.dart';
import 'package:authentipass/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class LoginUseCases implements UseCases<AuthResultsEntity,LoginParams> {
  final AuthRepository repository;

  LoginUseCases({required this.repository});

  @override
  Future<Either<Failure,AuthResultsEntity>> call(LoginParams params) async {
    return await repository.login(params.loginEntity);
  }
}

class LoginParams extends Equatable{
  final LoginEntity loginEntity;

  const LoginParams({required this.loginEntity});

  @override
  List<Object> get props => [loginEntity];
}