import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/profile/domain/repository/profile_repository.dart';
import 'package:dartz/dartz.dart';

class ConfirmPhoneNumberUsecase implements UseCases<void, NoParams> {
  final ProfileRepository repository;
  ConfirmPhoneNumberUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.confirmPhoneNumber();
  }
}