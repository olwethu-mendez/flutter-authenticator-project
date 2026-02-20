import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/auth/domain/entity/auth_results_entity.dart';
import 'package:authentipass/features/auth/domain/entity/refresh_token_entity.dart';
import 'package:authentipass/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class RefreshTokenUseCases implements UseCases<AuthResultsEntity, RefreshTokenParams> {
  final AuthRepository repository;

  RefreshTokenUseCases({required this.repository});

  @override
  Future<Either<Failure,AuthResultsEntity>> call(RefreshTokenParams params) async {
    return await repository.refreshToken(params.refreshTokenEntity);
  }
}

class RefreshTokenParams extends Equatable{
  final RefreshTokenEntity refreshTokenEntity;
  const RefreshTokenParams({required this.refreshTokenEntity});

  @override
  List<Object> get props => [refreshTokenEntity];
}