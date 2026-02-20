import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/profile/data/models/verify_code_model_dto.dart';
import 'package:authentipass/features/profile/domain/repository/profile_repository.dart';
import 'package:dartz/dartz.dart';

class VerifyCodeUsecase implements UseCases<void, VerifyCodeModelDto> {
  final ProfileRepository repository;
  VerifyCodeUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(VerifyCodeModelDto params) async {
    return await repository.verifyContactCode(params);
  }
}