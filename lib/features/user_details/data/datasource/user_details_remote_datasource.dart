import 'package:authentipass/core/error/exceptions.dart';
import 'package:authentipass/features/user_details/data/models/get_user_model.dart';
import 'package:dio/dio.dart';

abstract class UserDetailsRemoteDataSource {
  Future<GetUserModel> getSingleUser(String userId);
  Future<String> adminDeactivatesUser(String userId);
}

class UserDetailsRemoteDatasource implements UserDetailsRemoteDataSource{
  final Dio dio;
  UserDetailsRemoteDatasource({required this.dio});
  
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
  Future<String> adminDeactivatesUser(String userId) async {
    try{
      final response = await dio.put('/users/deactivate/$userId');
      return response.data as String? ?? "";
    } on DioException catch(e){
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<GetUserModel> getSingleUser(String userId) async {
    try{
      final response = await dio.get('/users/$userId');
      return GetUserModel.fromJson(response.data);
    } on DioException catch (e){
      _handleError(e);
      rethrow;
    }
  }

}