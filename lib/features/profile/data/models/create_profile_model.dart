// features/profile/data/models/create_profile_model.dart
import 'dart:io';

class CreateProfileModel {
  final String firstName;
  final String lastName;
  final String gender;
  final String? genderSelfDescription;
  final bool stayLoggedIn;
  final File? profilePicture;

  CreateProfileModel({
    required this.firstName,
    required this.lastName,
    required this.gender,
    this.genderSelfDescription,
    required this.stayLoggedIn,
    this.profilePicture,
  });

  // Since we are sending Multipart, we don't use a standard toJson() for the whole thing.
  // Instead, we convert fields to a Map for Dio's FormData.
  Map<String, dynamic> toMap() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'Gender': gender,
      'GenderSelfDescription': genderSelfDescription,
      'StayLoggedIn': stayLoggedIn.toString(),
    };
  }
}