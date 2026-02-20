import 'package:equatable/equatable.dart';

class RefreshTokenEntity extends Equatable{
  const RefreshTokenEntity({
    required this.token,
    required this.refreshToken,
  });
  final String? token;
  final String? refreshToken;

    @override
    List<Object?> get props => [
      token,
      refreshToken,
    ];
}