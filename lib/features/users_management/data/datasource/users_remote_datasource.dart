import 'package:authentipass/core/error/exceptions.dart';
import 'package:authentipass/features/users_management/data/models/create_user_model.dart';
import 'package:authentipass/features/users_management/data/models/users_list_model.dart';
import 'package:dio/dio.dart';

abstract class UsersRemoteDataSource {
  Future<List<UsersListModel>> getUsers();
  Future<void> createUser(CreateUserModel createUser);
}

class UsersRemoteDatasource implements UsersRemoteDataSource{
  final Dio dio;
  UsersRemoteDatasource({required this.dio});
  
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
  Future<List<UsersListModel>> getUsers() async {
    try{
      final response = await dio.get('/users');
      final List<dynamic> data = response.data;
      return data.map((json) => UsersListModel.fromJson(json)).toList();
    } on DioException catch (e){
      _handleError(e);
      rethrow;
    }
  }
  
@override
Future<void> createUser(CreateUserModel createUser) async {
  // Ensure we are sending strings for the simple fields
  final Map<String, dynamic> map = {
    "FirstName": createUser.firstName,
    "LastName": createUser.lastName,
    "Gender": createUser.gender,
    "GenderSelfDescription": createUser.genderSelfDescription ?? "",
    "Email": createUser.email,
    "CountryCode": createUser.countryCode,
    "PhoneNumber": createUser.phoneNumber,
    "PrefersEmail": createUser.prefersEmail.toString(),
  };

  if (createUser.profilePicture != null) {
    map["ProfilePicture"] = await MultipartFile.fromFile(
      createUser.profilePicture!.path,
      filename: createUser.profilePicture!.path.split('/').last,
      //contentType: MediaType('image', 'jpeg'),
    );
  }
  final formData = FormData.fromMap(map);
  
  // Use a try-catch specifically here to see if the error is before or after the request
  try {
    await dio.post('/users/create', data: formData);
  } on DioException catch (e) {    
    _handleError(e); // ✅ convert API error properly
    rethrow;
  }
}

}