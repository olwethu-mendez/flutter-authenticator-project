import 'package:authentipass/features/auth/domain/entity/refresh_token_entity.dart';

class RefreshTokenModel extends RefreshTokenEntity{
  const RefreshTokenModel({
    required super.token,
    required super.refreshToken,
  });
  
  factory RefreshTokenModel.fromJson(Map<String,dynamic> json){
    return RefreshTokenModel(
      token: json['token'],
      refreshToken: json['refreshToken'],
    );
  }

  Map<String,dynamic> toJson(){
    return {
      'token':token,
      'refreshToken':refreshToken
    };
  }
}