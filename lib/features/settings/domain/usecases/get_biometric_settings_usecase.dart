import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/settings/domain/repository/settings_repository.dart';
import 'package:dartz/dartz.dart';

class GetBiometricSettingsUsecase implements UseCases<bool?, NoParams> {
  final SettingsRepository repository;
  GetBiometricSettingsUsecase(this.repository);

  @override
  Future<Either<Failure, bool?>> call(NoParams params) async {
    return await repository.getBiometricAuthSettings();
  }  
}