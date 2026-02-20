import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/profile/data/models/change_password_model.dart';
import 'package:authentipass/features/profile/domain/repository/profile_repository.dart';
import 'package:dartz/dartz.dart';

class ChangePasswordUsecase implements UseCases<void, ChangePasswordModel> {
  final ProfileRepository repository;
  ChangePasswordUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(ChangePasswordModel params) async {
    return await repository.changePassword(params);
  }
}