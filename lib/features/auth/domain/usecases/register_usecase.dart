import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/auth/domain/entity/auth_results_entity.dart';
import 'package:authentipass/features/auth/domain/entity/register_entity.dart';
import 'package:authentipass/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class RegisterUseCases implements UseCases<AuthResultsEntity, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCases({required this.repository});

  @override
  Future<Either<Failure,AuthResultsEntity>> call(RegisterParams params) async {
    return await repository.register(params.registerEntity);
  }
}

class RegisterParams extends Equatable{
  final RegisterEntity registerEntity;

  const RegisterParams({required this.registerEntity});

  @override
  List<Object> get props => [registerEntity];
}