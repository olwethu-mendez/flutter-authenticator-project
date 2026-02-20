import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/user_details/domain/entities/get_user_entity.dart';
import 'package:authentipass/features/user_details/domain/repository/user_details_repository.dart';
import 'package:dartz/dartz.dart';

class GetSingleUserUsecase implements UseCases<GetUserEntity, String> {
  final UserDetailsRepository repository;
  GetSingleUserUsecase(this.repository);

  @override
  Future<Either<Failure, GetUserEntity>> call(String params) async {
    return await repository.getSingleUser(params);
  }
}