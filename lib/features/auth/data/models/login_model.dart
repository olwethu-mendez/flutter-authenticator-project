import 'package:authentipass/features/auth/domain/entity/login_entity.dart';

class LoginModel extends LoginEntity{
  const LoginModel({
    required super.countryCode,
    required super.username,
    required super.password,
    required super.stayLoggedIn,
  });
  
  factory LoginModel.fromJson(Map<String,dynamic> json){
    return LoginModel(
      countryCode: json['countryCode'],
      username: json['username'],
      password: json['password'],
      stayLoggedIn: json['stayLoggedIn'],
    );
  }

  Map<String,dynamic> toJson(){
    return {
      'countryCode':countryCode,
      'username':username,
      'password':password,
      'stayLoggedIn,':stayLoggedIn
    };
  }
}