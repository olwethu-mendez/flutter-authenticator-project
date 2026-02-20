import 'package:equatable/equatable.dart';

class RegisterEntity extends Equatable{
  const RegisterEntity({
    required this.email,
    required this.countryCode,
    required this.phoneNumber,
    this.prefersEmail,
    required this.password,
    required this.confirmPassword,
  });
  final String? email;
  final String? countryCode;
  final String? phoneNumber;
  final bool? prefersEmail;
  final String? password;
  final String? confirmPassword;

    @override
    List<Object?> get props => [
      email,
      countryCode,
      phoneNumber,
      prefersEmail,
      password,
      confirmPassword,
    ];
}