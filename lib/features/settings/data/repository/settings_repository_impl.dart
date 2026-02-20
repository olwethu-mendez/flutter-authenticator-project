import 'package:authentipass/core/error/exceptions.dart';
import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/features/settings/data/datasource/settings_local_datasource.dart';
import 'package:authentipass/features/settings/domain/repository/settings_repository.dart';
import 'package:dartz/dartz.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDatasource localDataSource;
  SettingsRepositoryImpl({
    required this.localDataSource,
  });
  
  @override
  Future<Either<Failure, bool?>> getBiometricAuthSettings() async {
    try{
      final isEnabled = await localDataSource.getBiometricAuthSettings();
      return Right(isEnabled);
    } on CacheException{
      return Left(
        CacheFailure(
          "Something went wrong retrieving your biometric authentication settings",
        ),
      );
    }
  }
  
  @override
  Future<Either<Failure, void>> setBiometricAuth(bool isEnabled) async {
    try {
      await localDataSource.setBiometricAuth(isEnabled);
      return Right(null);
    } on CacheException {
      return Left(
        CacheFailure(
          "Something went wrong setting your biometric authentication settings",
        ),
      );
    }
  }  
}