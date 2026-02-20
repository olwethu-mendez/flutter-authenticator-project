import 'package:authentipass/features/auth/domain/entity/forgot_password_entity.dart';

class ForgotPasswordModel extends ForgotPasswordEntity{
  const ForgotPasswordModel({
    required super.newPassword,
    required super.code,
    required super.username,
  });
  
  factory ForgotPasswordModel.fromJson(Map<String,dynamic> json){
    return ForgotPasswordModel(
      newPassword: json['newPassword'],
      code: json['code'],
      username: json['username'],
    );
  }

  Map<String,dynamic> toJson(){
    return {
      'newPassword':newPassword,
      'code':code,
      'username':username,
    };
  }
}