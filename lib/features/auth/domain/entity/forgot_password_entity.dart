import 'package:equatable/equatable.dart';

class ForgotPasswordEntity extends Equatable {
  const ForgotPasswordEntity({
  required this.newPassword,
  required this.code,
  required this.username
  });
  final String newPassword;
  final String code;
  final String username;

  @override
  List<Object?> get props => [
    newPassword,
    code,
    username,
  ];

}