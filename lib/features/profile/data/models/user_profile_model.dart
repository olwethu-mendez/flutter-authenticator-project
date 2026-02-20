class UserProfileModel {
  final String? userId;
  final String? profileId;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? emailAddress;
  final bool? emailConfirmed;
  final String? countryCode;
  final String? phoneNumber;
  final bool? phoneNumberConfirmed;
  final String? gender;
  final String? genderSelfDescription;
  final String? profilePictureUrl;
  final String? profilePictureName;
  final bool? isDeactivated;
  final bool? isDeactivatedByAdmin;
  final DateTime? deactivatedAt;
  final int? passwordLastUpdated;
  final DateTime? createdAt;
  
  const UserProfileModel({
    required this.userId,
    required this.profileId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.emailAddress,
    required this.emailConfirmed,
    required this.countryCode,
    required this.phoneNumber,
    required this.phoneNumberConfirmed,
    required this.gender,
    required this.genderSelfDescription,
    required this.profilePictureUrl,
    required this.profilePictureName,
    required this.isDeactivated,
    required this.isDeactivatedByAdmin, // Added
    this.deactivatedAt, // Added
    required this.createdAt,
    this.passwordLastUpdated,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['userId'], // Match your C# GetProfileDto
      profileId: json['profileId'], // Match your C# GetProfileDto
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      emailAddress: json['emailAddress'],
      emailConfirmed: json['emailConfirmed'], 
      countryCode: json['countryCode'],
      phoneNumber: json['phoneNumber'],
      phoneNumberConfirmed: json['phoneNumberConfirmed'],
      gender: json['gender'],
      genderSelfDescription: json['genderSelfDescription'],
      profilePictureUrl: json['profilePictureUrl'],
      profilePictureName: json['profilePictureName'],
      isDeactivated: json['isDeactivated'] ?? false,
      isDeactivatedByAdmin: json['isDeactivatedByAdmin'] ?? false,
      passwordLastUpdated: json['passwordLastUpdated'],
      deactivatedAt: json['deactivatedAt'] != null
          ? DateTime.parse(json['deactivatedAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'use': userId,
      'profileId': profileId,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'emailAddress': emailAddress,
      'emailConfirmed': emailConfirmed,
      'countryCode': countryCode,
      'phoneNumber': phoneNumber,
      'phoneNumberConfirmed': phoneNumberConfirmed,
      'gender': gender,
      'genderSelfDescription': genderSelfDescription,
      'profilePictureUrl': profilePictureUrl,
      'profilePictureName': profilePictureName,
      'isDeactivated': isDeactivated,
      'isDeactivatedByAdmin': isDeactivatedByAdmin,
      'deactivatedAt': deactivatedAt,
      'createdAt': createdAt,
      'passwordLastUpdated': passwordLastUpdated,
    };
  }
}
