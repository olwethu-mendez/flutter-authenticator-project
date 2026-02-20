import 'package:authentipass/core/error/exceptions.dart';
import 'package:authentipass/features/auth/data/models/auth_results_model.dart';
import 'package:authentipass/features/auth/data/models/auth_user_code_model.dart';
import 'package:authentipass/features/auth/data/models/forgot_password_model.dart';
import 'package:authentipass/features/auth/data/models/login_model.dart';
import 'package:authentipass/features/auth/data/models/refresh_token_model.dart';
import 'package:authentipass/features/auth/data/models/register_model.dart';
import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource{
  Future<AuthResultsModel> login(LoginModel login);
  Future<AuthResultsModel> register(RegisterModel register);
  Future<AuthResultsModel> refreshToken(RefreshTokenModel refreshToken);
  Future<AuthResultsModel> confirmEmail(AuthUserCodeModel code);
  Future<AuthResultsModel> confirmPhonenumber(AuthUserCodeModel code);
  Future<void> resendOtp(bool isEmail);
  Future<void> confirmForgotPassword(ForgotPasswordModel forgotPassword);
  Future<void> forgotPassword(String username);
  Future<bool> isAuthenticated();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource{
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});
// Inside AuthRemoteDataSourceImpl
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
// Inside AuthRemoteDataSourceImpl
  @override
  Future<AuthResultsModel> login(LoginModel login) async {
    // Just use the relative path; Dio takes care of the rest
    try{
    final res = await dio.post('/authentication/login', data: login.toJson());
    return AuthResultsModel.fromJson(res.data);
    } on DioException catch (e){
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<AuthResultsModel> confirmEmail(AuthUserCodeModel code) async {
    // Just use the relative path; Dio takes care of the rest
    try{
    final res = await dio.post('/authentication/confirm-email', data: code.toJson());
    return AuthResultsModel.fromJson(res.data);
    } on DioException catch (e){
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<AuthResultsModel> confirmPhonenumber(AuthUserCodeModel code) async {
    // Just use the relative path; Dio takes care of the rest
    try{
    final res = await dio.post('/authentication/confirm-phone', data: code.toJson());
    return AuthResultsModel.fromJson(res.data);
    } on DioException catch (e){
      _handleError(e);
      rethrow;
    }
  }

  @override
Future<void> resendOtp(bool isEmail) async {
  try {
    final type = isEmail ? "email" : "sms";
    await dio.post('/authentication/resend-otp/$type');
  } on DioException catch (e) {
    _handleError(e);
    rethrow;
  }
}

  @override
Future<void> forgotPassword(String username) async {
  try {
    await dio.post('/authentication/forgot-password?username=$username',);
  } on DioException catch (e) {
    _handleError(e);
    rethrow;
  }
}

  @override
Future<void> confirmForgotPassword(ForgotPasswordModel resetPassword) async {
  try {
    await dio.post('/authentication/confirm-forgot-password', data: resetPassword.toJson());
  } on DioException catch (e) {
    _handleError(e);
    rethrow;
  }
}

  @override
  Future<AuthResultsModel> register(RegisterModel register) async {
    try{
    final res = await dio.post('/authentication/register', data: register.toJson());
    return AuthResultsModel.fromJson(res.data);
    } on DioException catch (e){
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<AuthResultsModel> refreshToken(RefreshTokenModel refreshToken)async {
    try{
    final res = await dio.post('/authentication/refresh-token', data: refreshToken.toJson());
    return AuthResultsModel.fromJson(res.data);
    } on DioException catch (e){
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try{
      final res = await dio.get('/authentication/check-auth');
    return res.statusCode == 200 && res.data['status'] == "User is authenticated";
    } on DioException catch (e){
      if (e.response?.statusCode == 401) return false;
    _handleError(e);
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try{
    await dio.post('/authentication/logout');
    } on DioException catch (e){
      _handleError(e);
      rethrow;
    }
  }
}