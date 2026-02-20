class UpdateProfileModel {
  final String firstName;
  final String lastName;
  final String? gender;
  final String? genderSelfDescription;

  UpdateProfileModel({
    required this.firstName,
    required this.lastName,
    this.gender,
    this.genderSelfDescription,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'gender': gender,
    'genderSelfDescription': genderSelfDescription,
  };
}