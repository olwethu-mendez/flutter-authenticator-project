import 'package:equatable/equatable.dart';

class AuthResultsEntity extends Equatable{
  const AuthResultsEntity({
    required this.token,
    required this.refreshToken,
    required this.expirationDate,
    required this.hasProfile, // Add this!
  });
  final String? token;
  final String? refreshToken;
  final DateTime? expirationDate;
  final bool hasProfile; // Derived from your token claim

    @override
    List<Object?> get props => [
      token,
      refreshToken,
      expirationDate,
      hasProfile,
    ];
}