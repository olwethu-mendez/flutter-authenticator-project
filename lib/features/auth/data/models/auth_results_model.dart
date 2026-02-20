import 'package:authentipass/features/auth/domain/entity/auth_results_entity.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Import this

class AuthResultsModel extends AuthResultsEntity{
  const AuthResultsModel({
    required super.token,
    required super.refreshToken,
    required super.expirationDate,
    required super.hasProfile,
  });
  
factory AuthResultsModel.fromJson(Map<String, dynamic> json) {
  try {
    final String? token = json['token'];
    bool hasProfile = false;

    if (token != null && token.isNotEmpty) {
      final decoded = JwtDecoder.decode(token);
      // Use .toString() to prevent type mismatch crashes
      hasProfile = decoded['HasProfile']?.toString().toLowerCase() == 'true';
    }

    return AuthResultsModel(
      token: token,
      refreshToken: json['refreshToken']?.toString(), // Safely handle null/missing
      expirationDate: json['expirationDate'] != null 
          ? DateTime.tryParse(json['expirationDate'].toString()) 
          : null,
      hasProfile: hasProfile,
    );
  } catch (e) {
    // If this fails, the catch block in your Bloc will trigger
    throw Exception("Model Parsing Error: $e");
  }
}

  Map<String,dynamic> toJson(){
    return {
      'token':token,
      'refreshToken':refreshToken,
      'expirationDate':expirationDate,
      'hasProfile':hasProfile,
    };
  }
}