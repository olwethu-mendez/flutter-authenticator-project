import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsLocalDatasource {
  Future<void> setBiometricAuth(bool isEnabled);
  Future<bool?> getBiometricAuthSettings();
}

class SettingsLocalDatasourceImpl implements SettingsLocalDatasource {
  final SharedPreferences sharedPreferences;

  static const String cachedBiometricAuth = 'CACHED_BIOMETRIC_AUTH';

  SettingsLocalDatasourceImpl({required this.sharedPreferences});
  
  @override
  Future<void> setBiometricAuth(bool isEnabled) async {
    await sharedPreferences.setBool(cachedBiometricAuth, isEnabled);
  }
  
  @override
  Future<bool?> getBiometricAuthSettings() async {
    return sharedPreferences.getBool(cachedBiometricAuth);
  }  
}