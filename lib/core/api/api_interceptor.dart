import 'package:dio/dio.dart';
import 'package:authentipass/features/auth/data/datasources/auth_local_datasource.dart';

class ApiInterceptor extends Interceptor {
  final AuthLocalDataSource localDataSource;
  final Dio dio; // Pass dio to retry requests

  ApiInterceptor(this.localDataSource, this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await localDataSource.getCachedToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    // IMPORTANT: Only set application/json if we aren't sending FormData
    if (options.data is! FormData) {
    options.headers['Content-Type'] = 'application/json';
  } else {
    // IMPORTANT: Remove the content-type header for FormData 
    // to let Dio generate it with the correct boundary!
    options.headers.remove('Content-Type');
  }
    
    options.headers['Accept'] = 'application/json';
    return handler.next(options);
  }

// core/api/api_interceptor.dart

@override
void onError(DioException err, ErrorInterceptorHandler handler) async {
  // Only handle 401 Unauthorized
  if (err.response?.statusCode == 401) {
    final refreshToken = await localDataSource.getCachedRefreshToken();
    final accessToken = await localDataSource.getCachedToken();

    if (refreshToken != null && accessToken != null) {
      // Use a CLEAN Dio instance to avoid interceptor loops
      final refreshDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));

      try {
        final response = await refreshDio.post('/authentication/refresh-token', data: {
          'token': accessToken,
          'refreshToken': refreshToken,
        });

        if (response.statusCode == 200) {
          final newToken = response.data['token'];
          final newRefresh = response.data['refreshToken'];

          await localDataSource.cacheToken(newToken);
          await localDataSource.cacheRefreshToken(newRefresh);

          // Retry the original request with the new token
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';
          
          final responseRetry = await dio.fetch(opts); 
          return handler.resolve(responseRetry);
        }
      } catch (e) {
        // Refresh failed (Refresh Token expired) -> Clear all and let the error pass
        await localDataSource.clearToken();
        // The error will propagate to the DataSource, which will throw InvalidCredentialsException
      }
    }
  }
  return handler.next(err);
}
}