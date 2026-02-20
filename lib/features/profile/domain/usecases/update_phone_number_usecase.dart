import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/profile/data/models/update_phone_number_model.dart';
import 'package:authentipass/features/profile/domain/repository/profile_repository.dart';
import 'package:dartz/dartz.dart';

class UpdatePhoneNumberUsecase implements UseCases<void, UpdatePhoneNumberModel> {
  final ProfileRepository repository;
  UpdatePhoneNumberUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdatePhoneNumberModel params) async {
    return await repository.updatePhoneNumber(params);
  }
}