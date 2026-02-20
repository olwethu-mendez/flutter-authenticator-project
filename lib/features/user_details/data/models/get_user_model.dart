import 'package:authentipass/features/user_details/domain/entities/get_user_entity.dart';

class GetUserModel extends GetUserEntity {
  const GetUserModel({
    required super.userId,
    required super.profileId,
    required super.firstName,
    required super.lastName,
    required super.username,
    required super.emailAddress,
    required super.emailConfirmed,
    required super.phoneNumber,
    required super.phoneNumberConfirmed,
    required super.profilePictureUrl,
    required super.isDeactivated,
    required super.isDeactivatedByAdmin, // Added
    super.deactivatedAt,                 // Added
    required super.createdAt,
  });

  factory GetUserModel.fromJson(Map<String, dynamic> json) {
    return GetUserModel(
      userId: json['userId'], // Match your C# GetProfileDto
      profileId: json['profileId'], // Match your C# GetProfileDto
      firstName: json['firstName'],
      lastName: json['lastName'],
      username: json['username'],
      emailAddress: json['emailAddress'],
      emailConfirmed: json['emailConfirmed'],
      phoneNumber: json['phoneNumber'],
      phoneNumberConfirmed: json['phoneNumberConfirmed'],
      profilePictureUrl: json['profilePictureUrl'],
      isDeactivated: json['isDeactivated'] ?? false,
      isDeactivatedByAdmin: json['isDeactivatedByAdmin'] ?? false,
      deactivatedAt: json['deactivatedAt'] != null ? DateTime.parse(json['deactivatedAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String,dynamic> toJson(){
    return {
      'userId':userId,
      'profileId':profileId,
      'firstName':firstName,
      'lastName':lastName,
      'username':username,
      'emailAddress':emailAddress,
      'emailConfirmed':emailConfirmed,
      'phoneNumber':phoneNumber,
      'phoneNumberConfirmed':phoneNumberConfirmed,
      'profilePictureUrl':profilePictureUrl,
      'isDeactivated':isDeactivated,      
      'isDeactivatedByAdmin':isDeactivatedByAdmin,
      'deactivatedAt':deactivatedAt,
      'createdAt':createdAt,
    };
  }
}