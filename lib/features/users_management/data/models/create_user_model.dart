// features/profile/data/models/create_profile_model.dart
import 'package:authentipass/features/users_management/domain/entities/create_user_entity.dart';

class CreateUserModel extends CreateUserEntity {
  const CreateUserModel({
    required super.firstName,
    required super.lastName,
    required super.gender,
    super.genderSelfDescription,
    super.profilePicture, 
    required super.email, 
    required super.countryCode, 
    required super.phoneNumber, 
    required super.prefersEmail,
  });

  // Since we are sending Multipart, we don't use a standard toJson() for the whole thing.
  // Instead, we convert fields to a Map for Dio's FormData.
  Map<String, dynamic> toMap() {
    return {
      'FirstName':firstName,
      'LastName':lastName,
      'Gender':gender,
      'GenderSelfDescription':genderSelfDescription,
      'ProfilePicture':profilePicture,
      'Email':email,
      'CountryCode':countryCode,
      'PhoneNumber':phoneNumber,
      'PrefersEmail':prefersEmail.toString(),
    };
  }
}