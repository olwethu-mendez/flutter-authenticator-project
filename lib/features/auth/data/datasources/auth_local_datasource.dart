import 'dart:convert';

import 'package:authentipass/features/profile/data/models/user_profile_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<void> cacheRefreshToken(String refreshToken);
  Future<String?> getCachedToken();
  Future<String?> getCachedRefreshToken();
  Future<void> clearToken();
  Future<void> cacheUser(UserProfileModel user); 
  Future<UserProfileModel?> getCachedUser(); 
  Future<void> cacheBiometricCredentials(String username, String password, String? countryCode);
  Future<Map<String, String?>> getBiometricCredentials();
  Future<void> clearBiometricCountryCode();
  Future<void> clearBiometricCredentials();
  Future<bool> hasBiometricCredentials();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource{
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage;
  //other type of storage
  static const String cachedTokens = 'CACHED_TOKENS';
  static const String cachedRefreshedTokens = 'CACHED_REFRESHED_TOKENS';
  static const String cachedUser = 'CACHED_USER';
  static const String cachedBiometricUsername = 'CACHED_BIOMETRIC_USERNAME';
  static const String cachedBiometricPassword = 'CACHED_BIOMETRIC_PASSWORD';
  static const String cachedBiometricCountryCode = 'CACHED_BIOMETRIC_COUNTRY_CODE';

  AuthLocalDataSourceImpl({required this.sharedPreferences, required this.secureStorage});

  @override
  
  Future<void> cacheRefreshToken(String refreshToken) async {
    await secureStorage.write(key: cachedRefreshedTokens, value: refreshToken);
  }

  @override
  Future<void> cacheToken(String token) async {
    await sharedPreferences.setString(cachedTokens, token);
  }

  @override
  Future<void> cacheUser(UserProfileModel user) async {
    await sharedPreferences.setString(cachedUser, json.encode(user.toJson()));
  }

  @override
  Future<void> clearToken() async {
    await sharedPreferences.remove(cachedTokens);
    //await ...remove(refreshToken); //i think
    await sharedPreferences.remove(cachedUser);
    await secureStorage.delete(key: cachedRefreshedTokens);
  }

  @override  
  Future<String?> getCachedRefreshToken() async {
    return await secureStorage.read(key: cachedRefreshedTokens);
  }

  @override
  Future<String?> getCachedToken() async{
    return sharedPreferences.getString(cachedTokens);
  }

  @override
  Future<UserProfileModel?> getCachedUser() async{
    final userJsonString = sharedPreferences.getString(cachedUser);

    if(userJsonString != null){
      return UserProfileModel.fromJson(json.decode(userJsonString));
    }
    return null;
  }
  
  @override
  Future<void> cacheBiometricCredentials(String username, String password, String? countryCode) async {
    await secureStorage.write(key: cachedBiometricUsername, value: username);
    await secureStorage.write(key: cachedBiometricPassword, value: password);
    if(countryCode != null) await secureStorage.write(key: cachedBiometricCountryCode, value: countryCode);
  }
  
  @override
  Future<Map<String, String?>> getBiometricCredentials() async {
    final username = await secureStorage.read(key: cachedBiometricUsername);
    final password = await secureStorage.read(key: cachedBiometricPassword);
    final countryCode = await secureStorage.read(key: cachedBiometricCountryCode);

    return {
      'username': username,
      'password': password,
      'countryCode': countryCode
    };
  }
  
  @override
  Future<void> clearBiometricCredentials() async {
    await secureStorage.delete(key: cachedBiometricUsername);
    await secureStorage.delete(key: cachedBiometricPassword);
    await secureStorage.delete(key: cachedBiometricCountryCode);
  }
  
  @override
  Future<void> clearBiometricCountryCode() async {
    await secureStorage.delete(key: cachedBiometricCountryCode);
  }  

  @override
  Future<bool> hasBiometricCredentials() async {
    final username = await secureStorage.read(key: cachedBiometricUsername);
    return username != null && username.isNotEmpty;
  }
}