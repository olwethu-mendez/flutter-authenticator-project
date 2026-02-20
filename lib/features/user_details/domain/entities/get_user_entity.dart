import 'package:equatable/equatable.dart';

class GetUserEntity extends Equatable{
  const GetUserEntity({    
    required this.userId,
    required this.profileId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.emailAddress,
    required this.emailConfirmed,
    required this.phoneNumber,
    required this.phoneNumberConfirmed,
    required this.profilePictureUrl,
    required this.isDeactivated,
    required this.isDeactivatedByAdmin, // Added
    this.deactivatedAt,                 // Added
    required this.createdAt,
  });
  final String? userId;
  final String? profileId;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? emailAddress;
  final bool? emailConfirmed;
  final String? phoneNumber;
  final bool? phoneNumberConfirmed;
  final String? profilePictureUrl;
  final bool isDeactivated;
  final bool? isDeactivatedByAdmin;
  final DateTime? deactivatedAt;
  final DateTime? createdAt;

    @override
    List<Object?> get props => [
      userId,
      profileId,
      firstName,
      lastName,
      username,
      emailAddress,
      emailConfirmed,
      phoneNumber,
      phoneNumberConfirmed,
      profilePictureUrl,
      isDeactivated,
      isDeactivatedByAdmin,
      deactivatedAt,
      createdAt,
    ];
    GetUserEntity copyWith({
  String? userId,
  String? profileId,
  String? firstName,
  String? lastName,
  String? username,
  String? emailAddress,
  bool? emailConfirmed,
  String? phoneNumber,
  bool? phoneNumberConfirmed,
  String? profilePictureUrl,
  bool? isDeactivated,
  bool? isDeactivatedByAdmin,
  DateTime? deactivatedAt,
  DateTime? createdAt,
}) {
  return GetUserEntity(
    userId: userId ?? this.userId,
    profileId: profileId ?? this.profileId,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    username: username ?? this.username,
    emailAddress: emailAddress ?? this.emailAddress,
    emailConfirmed: emailConfirmed ?? this.emailConfirmed,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    phoneNumberConfirmed: phoneNumberConfirmed ?? this.phoneNumberConfirmed,
    profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    isDeactivated: isDeactivated ?? this.isDeactivated,
    isDeactivatedByAdmin: isDeactivatedByAdmin ?? this.isDeactivatedByAdmin,
    deactivatedAt: deactivatedAt ?? this.deactivatedAt,
    createdAt: createdAt ?? this.createdAt,
  );
}
}