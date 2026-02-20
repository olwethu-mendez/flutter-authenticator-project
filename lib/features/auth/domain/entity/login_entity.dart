import 'package:equatable/equatable.dart';

class LoginEntity extends Equatable{
  const LoginEntity({
    required this.countryCode,
    required this.username,
    required this.password,
    required this.stayLoggedIn
  });
  final String? countryCode;
  final String? username;
  final String? password;
  final bool? stayLoggedIn;

    @override
    List<Object?> get props => [
      countryCode,
      username,
      password,
      stayLoggedIn,
    ];
}