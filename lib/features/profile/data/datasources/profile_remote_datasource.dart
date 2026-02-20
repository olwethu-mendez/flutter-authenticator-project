import 'dart:io';

import 'package:authentipass/core/error/exceptions.dart';
import 'package:authentipass/features/auth/data/models/auth_results_model.dart';
import 'package:authentipass/features/profile/data/models/change_password_model.dart';
import 'package:authentipass/features/profile/data/models/create_profile_model.dart';
import 'package:authentipass/features/profile/data/models/deactivate_account_model.dart';
import 'package:authentipass/features/profile/data/models/update_email_model.dart';
import 'package:authentipass/features/profile/data/models/update_phone_number_model.dart';
import 'package:authentipass/features/profile/data/models/update_profile_model.dart';
import 'package:authentipass/features/profile/data/models/user_profile_model.dart';
import 'package:authentipass/features/profile/data/models/verify_code_model_dto.dart';
import 'package:dio/dio.dart';

abstract class ProfileRemoteDataSource {
  Future<AuthResultsModel> createProfile(CreateProfileModel profile);
  Future<UserProfileModel> getProfile();
  Future<void> updateProfile(UpdateProfileModel updateProfile);
  Future<void> updateEmail(UpdateEmailModel updateEmail);
  Future<void> updatePhoneNumber(UpdatePhoneNumberModel updatePhoneNumber);
  Future<void> confirmPhoneNumber();
  Future<void> confirmEmail();
  Future<void> changePassword(ChangePasswordModel changePassword);
  Future<void> verifyContactCode(VerifyCodeModelDto verifyCode);
  Future<void> setPreferredContactMode(String mode);
  Future<void> updateProfilePicture(File? profilePicture);
  Future<AuthResultsModel> activateProfile(DeactivateAccountModel deactivate);
  Future<void> deactivateProfile(DeactivateAccountModel deactivate);
}

class ProfileRemoteDatasource implements ProfileRemoteDataSource {
  final Dio dio;
  ProfileRemoteDatasource({required this.dio});


void _handleError(DioException e) {
  // Check if our Interceptor already put a custom exception in the 'error' field
  if (e.error is InvalidRequestException) {
    throw e.error as InvalidRequestException;
  }
  if (e.error is InvalidCredentialsExceptions) {
    throw e.error as InvalidCredentialsExceptions;
  }

  // Fallback: If Interceptor didn't catch it, try to parse the raw response
  String message = "An unexpected error occurred";
  if (e.response?.data != null && e.response?.data is Map) {
    message = e.response?.data['error'] ?? message;
  }

  if (e.response?.statusCode == 400) {
    throw InvalidRequestException(message);
  } else {
    throw ServerException(message);
  }
}
  
@override
Future<AuthResultsModel> createProfile(CreateProfileModel profile) async {
  // Ensure we are sending strings for the simple fields
  final Map<String, dynamic> map = {
    "FirstName": profile.firstName,
    "LastName": profile.lastName,
    "Gender": profile.gender,
    "GenderSelfDescription": profile.genderSelfDescription ?? "",
    "StayLoggedIn": profile.stayLoggedIn.toString(),
  };

  if (profile.profilePicture != null) {
    map["ProfilePicture"] = await MultipartFile.fromFile(
      profile.profilePicture!.path,
      filename: profile.profilePicture!.path.split('/').last,
      //contentType: MediaType('image', 'jpeg'),
    );
  }

  final formData = FormData.fromMap(map);
  
  // Use a try-catch specifically here to see if the error is before or after the request
  try {
    final response = await dio.post('/profile/create', data: formData);
    return AuthResultsModel.fromJson(response.data);
  } on DioException catch (e) {    
    _handleError(e); // ✅ convert API error properly
    rethrow;
  }
}
  
@override
Future<void> updateProfile(UpdateProfileModel updateProfile) async {  
  // Use a try-catch specifically here to see if the error is before or after the request
  try {
    await dio.put('/profile/update', data: updateProfile.toJson());
  } on DioException catch (e) {    
    _handleError(e); // ✅ convert API error properly
    rethrow;
  }
}
  
@override
Future<void> updateEmail(UpdateEmailModel updateEmail) async {  
  // Use a try-catch specifically here to see if the error is before or after the request
  try {
    await dio.put('/profile/update-email', data: updateEmail.toJson());
  } on DioException catch (e) {    
    _handleError(e); // ✅ convert API error properly
    rethrow;
  }
}
  
@override
Future<void> updatePhoneNumber(UpdatePhoneNumberModel updatePhoneNumber) async {  
  // Use a try-catch specifically here to see if the error is before or after the request
  try {
    await dio.put('/profile/update-phone-number', data: updatePhoneNumber.toJson());
  } on DioException catch (e) {    
    _handleError(e); // ✅ convert API error properly
    rethrow;
  }
}
  
@override
Future<void> updateProfilePicture(File? profilePicture) async {
  // Ensure we are sending strings for the simple fields
  final Map<String, dynamic> map = {};

  if (profilePicture != null) {
    map["ProfilePicture"] = await MultipartFile.fromFile(
      profilePicture.path,
      filename: profilePicture.path.split('/').last,
      //contentType: MediaType('image', 'jpeg'),
    );
  }

  final formData = FormData.fromMap(map);
  
  // Use a try-catch specifically here to see if the error is before or after the request
  try {
    await dio.put('/profile/update-profile-pictue', data: formData);
  } on DioException catch (e) {    
    _handleError(e); // ✅ convert API error properly
    rethrow;
  }
}

  @override
  Future<UserProfileModel> getProfile() async {
    try{
    final response = await dio.get('/profile');
    return UserProfileModel.fromJson(response.data);
        } on DioException catch (e){
      _handleError(e);
      rethrow;
    }
  }
  
  @override
  Future<AuthResultsModel> activateProfile(DeactivateAccountModel deactivate) async {
    try {
      final response = await dio.put('/profile/activate', data: deactivate.toJson());
      return AuthResultsModel.fromJson(response.data);
    } on DioException catch (e) {    
      _handleError(e); // ✅ convert API error properly
      rethrow;
    }
  }
  
  @override
  Future<void> deactivateProfile(DeactivateAccountModel deactivate) async {
    try {
      await dio.put('/profile/deactivate', data: deactivate.toJson());
    } on DioException catch (e) {    
      _handleError(e); // ✅ convert API error properly
      rethrow;
    }
  }
  
  @override
  Future<void> changePassword(ChangePasswordModel changePassword) {
    try {
      return dio.put('/profile/change-password', data: changePassword.toJson());
    } on DioException catch (e) {    
      _handleError(e); // ✅ convert API error properly
      rethrow;
    }
  }
  
  @override
  Future<void> confirmEmail() {
    try {
      return dio.post('/profile/confirm-email');
    } on DioException catch (e) {    
      _handleError(e); // ✅ convert API error properly
      rethrow;
    }
  }
  
  @override
  Future<void> confirmPhoneNumber() {
    try {
      return dio.post('/profile/confirm-phone-number');
    } on DioException catch (e) {    
      _handleError(e); // ✅ convert API error properly
      rethrow;
    }
  }
  
  @override
  Future<void> setPreferredContactMode(String mode) {
    try {
      return dio.put('/profile/set-preferred-contact-mode', data: {'mode': mode});
    } on DioException catch (e) {    
      _handleError(e); // ✅ convert API error properly
      rethrow;
    }
  }
  
  @override
  Future<void> verifyContactCode(VerifyCodeModelDto verifyCode) {
    try {
      return dio.post('/profile/verify-contact-code', data: verifyCode.toJson());
    } on DioException catch (e) {    
      _handleError(e); // ✅ convert API error properly
      rethrow;
    }
  }
}
