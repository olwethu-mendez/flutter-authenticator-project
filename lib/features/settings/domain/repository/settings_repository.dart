import 'package:authentipass/core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class SettingsRepository {
  Future<Either<Failure,void>> setBiometricAuth(bool isEnabled);
  Future<Either<Failure,bool?>> getBiometricAuthSettings();
}