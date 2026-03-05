// core/api/error_interceptor.dart

import 'package:authentipass/core/error/exceptions.dart';
import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Extract message from Backend
    String message = "An unexpected error occurred";
    
    if (err.response?.data != null && err.response?.data is Map) {
      final data = err.response!.data as Map<String, dynamic>;

      if(data.containsKey('errors') && data['errors'] is Map){
        final validationErrors = data['errors'] as Map<String, dynamic>;

        message = validationErrors.values.expand((e) =>
          e is List ? e : [e.toString()]).join("\n");
      }
      else{
        message = data['error'] ?? data['message'] ?? message;
      }
    }
    print("API ERROR DATA: ${err.response?.data}");
    // Map HTTP Status Codes to your Custom Exceptions
switch (err.response?.statusCode) {
      case 400:
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            type: DioExceptionType.badResponse,
            error: InvalidRequestException(message), // Pass your custom exception here
          ),
        );
      case 401:
        return handler.next(err); 
      case 403:
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            type: DioExceptionType.badResponse,
            error: InvalidCredentialsExceptions(message),
          ),
        );
      default:
        return handler.next(err); // Let other errors pass through naturally
    }
  }
}