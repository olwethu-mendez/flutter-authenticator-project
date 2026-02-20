import 'package:authentipass/features/auth/domain/entity/register_entity.dart';

class RegisterModel extends RegisterEntity{
  const RegisterModel({
    required super.email,
    required super.countryCode,
    required super.phoneNumber,
    super.prefersEmail,
    required super.password,
    required super.confirmPassword,
  });
  
  factory RegisterModel.fromJson(Map<String,dynamic> json){
    return RegisterModel(
      email: json['email'],
      countryCode: json['countryCode'],
      phoneNumber: json['phoneNumber'],
      prefersEmail: json['prefersEmail'],
      password: json['password'],
      confirmPassword: json['confirmPassword'],
    );
  }

  Map<String,dynamic> toJson(){
    return {
      'email':email,
      'countryCode':countryCode,
      'phoneNumber':phoneNumber,
      'prefersEmail':prefersEmail,
      'password':password,
      'confirmPassword':confirmPassword,
    };
  }
}