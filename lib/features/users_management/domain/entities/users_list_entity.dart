import 'package:equatable/equatable.dart';

class UsersListEntity extends Equatable{
  const UsersListEntity({    
    required this.userId,
    required this.profileId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.emailConfirmed,
    required this.phoneNumberConfirmed,
    required this.profilePictureUrl,
    required this.isDeactivated,
    required this.isDeactivatedByAdmin,
  });
  final String? userId;
  final String? profileId;
  final String? firstName;
  final String? lastName;
  final String? username;
  final bool? emailConfirmed;
  final bool? phoneNumberConfirmed;
  final String? profilePictureUrl;
  final bool isDeactivated;
  final bool? isDeactivatedByAdmin;

    @override
    List<Object?> get props => [
      userId,
      profileId,
      firstName,
      lastName,
      username,
      emailConfirmed,
      phoneNumberConfirmed,
      profilePictureUrl,
      isDeactivated,
      isDeactivatedByAdmin,
    ];
    UsersListEntity copyWith({
  String? userId,
  String? profileId,
  String? firstName,
  String? lastName,
  String? username,
  bool? emailConfirmed,
  bool? phoneNumberConfirmed,
  String? profilePictureUrl,
  bool? isDeactivated,
  bool? isDeactivatedByAdmin
}) {
  return UsersListEntity(
    userId: userId ?? this.userId,
    profileId: profileId ?? this.profileId,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    username: username ?? this.username,
    emailConfirmed: emailConfirmed ?? this.emailConfirmed,
    phoneNumberConfirmed: phoneNumberConfirmed ?? this.phoneNumberConfirmed,
    profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    isDeactivated: isDeactivated ?? this.isDeactivated,
    isDeactivatedByAdmin: isDeactivatedByAdmin ?? this.isDeactivatedByAdmin,
  );
}
}