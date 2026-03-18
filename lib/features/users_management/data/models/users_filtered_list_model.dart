class UsersFilteredListModel {
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

  const UsersFilteredListModel({
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
    required this.isDeactivatedByAdmin
  });

  factory UsersFilteredListModel.fromJson(Map<String, dynamic> json) {
    return UsersFilteredListModel(
      userId: json['userId'], // Match your C# GetProfileDto
      profileId: json['profileId'], // Match your C# GetProfileDto
      firstName: json['firstName'],
      lastName: json['lastName'],
      username: json['username'],
      emailConfirmed: json['emailConfirmed'],
      emailAddress: json['emailAddress'],
      phoneNumberConfirmed: json['phoneNumberConfirmed'],
      phoneNumber: json['phoneNumber'],
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
      'emailAddress':emailAddress,
      'phoneNumberConfirmed':phoneNumberConfirmed,
      'phoneNumber':phoneNumber,
      'profilePictureUrl':profilePictureUrl,
      'isDeactivated':isDeactivated
    };
  }
}