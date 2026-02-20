import 'package:authentipass/features/users_management/domain/entities/users_list_entity.dart';

class UsersListModel extends UsersListEntity {
  const UsersListModel({
    required super.userId,
    required super.profileId,
    required super.firstName,
    required super.lastName,
    required super.username,
    required super.emailConfirmed,
    required super.phoneNumberConfirmed,
    required super.profilePictureUrl,
    required super.isDeactivated,
    required super.isDeactivatedByAdmin, // Added
  });

  factory UsersListModel.fromJson(Map<String, dynamic> json) {
    return UsersListModel(
      userId: json['userId'], // Match your C# GetProfileDto
      profileId: json['profileId'], // Match your C# GetProfileDto
      firstName: json['firstName'],
      lastName: json['lastName'],
      username: json['username'],
      emailConfirmed: json['emailConfirmed'],
      phoneNumberConfirmed: json['phoneNumberConfirmed'],
      profilePictureUrl: json['profilePictureUrl'],
      isDeactivated: json['isDeactivated'] ?? false,
      isDeactivatedByAdmin: json['isDeactivatedByAdmin'] ?? false,
    );
  }

  Map<String,dynamic> toJson(){
    return {
      'userId':userId,
      'profileId':profileId,
      'firstName':firstName,
      'lastName':lastName,
      'username':username,
      'emailConfirmed':emailConfirmed,
      'phoneNumberConfirmed':phoneNumberConfirmed,
      'profilePictureUrl':profilePictureUrl,
      'isDeactivated':isDeactivated
    };
  }
}