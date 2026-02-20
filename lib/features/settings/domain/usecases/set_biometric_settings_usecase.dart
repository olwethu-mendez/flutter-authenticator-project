import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/settings/domain/repository/settings_repository.dart';
import 'package:dartz/dartz.dart';

class SetBiometricSettingsUsecase implements UseCases<void, bool> {
  final SettingsRepository repository;
  SetBiometricSettingsUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(bool isEnabled) async {
    return await repository.setBiometricAuth(isEnabled);
  }  
}