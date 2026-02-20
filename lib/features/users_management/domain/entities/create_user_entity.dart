import 'dart:io';

import 'package:equatable/equatable.dart';

class CreateUserEntity extends Equatable{
  const CreateUserEntity({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.genderSelfDescription,
    required this.profilePicture,
    required this.email,
    required this.countryCode,
    required this.phoneNumber,
    required this.prefersEmail,
  });
  final String firstName;
  final String lastName;
  final String gender;
  final String? genderSelfDescription;
  final File? profilePicture;
  final String? email;
  final String? countryCode;
  final String? phoneNumber;
  final bool? prefersEmail;

    @override
    List<Object?> get props => [
      firstName,
      lastName,
      gender,
      genderSelfDescription,
      profilePicture,
      email,
      countryCode,
      phoneNumber,
      prefersEmail,
    ];
    CreateUserEntity copyWith({
  String? firstName,
  String? lastName,
  String? gender,
  String? genderSelfDescription,
  File? profilePicture,
  String? email,
  String? countryCode,
  String? phoneNumber,
  bool? prefersEmail,
  }) {
  return CreateUserEntity(
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    email: email ?? this.email,
    countryCode: countryCode ?? this.countryCode,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    gender: gender ?? this.gender,
    genderSelfDescription: genderSelfDescription ?? this.genderSelfDescription,
    profilePicture: profilePicture ?? this.profilePicture,
    prefersEmail: prefersEmail ?? this.prefersEmail,
  );
}


}