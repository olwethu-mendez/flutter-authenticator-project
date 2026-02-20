import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/profile/domain/repository/profile_repository.dart';
import 'package:dartz/dartz.dart';

class SetPreferredContactModeUsecase implements UseCases<void, String> {
  final ProfileRepository repository;
  SetPreferredContactModeUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.setPreferredContactMode(params);
  }
}