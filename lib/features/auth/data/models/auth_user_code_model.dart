class AuthUserCodeModel {
  final String userId;
  final String code;

  const AuthUserCodeModel({
    required this.userId,              // Added
    required this.code,
  });

  factory AuthUserCodeModel.fromJson(Map<String, dynamic> json) {
    return AuthUserCodeModel(
      userId: json['userId'] as String, // Match your C# GetProfileDto
      code: json['code'] as String,
    );
  }

  Map<String,String> toJson(){
    return {
      'userId':userId,
      'code':code,
    };
  }
}