import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/features/auth/data/models/auth_user_code_model.dart';
import 'package:authentipass/features/auth/domain/entity/auth_results_entity.dart';
import 'package:authentipass/features/auth/domain/entity/forgot_password_entity.dart';
import 'package:authentipass/features/auth/domain/entity/login_entity.dart';
import 'package:authentipass/features/auth/domain/entity/refresh_token_entity.dart';
import 'package:authentipass/features/auth/domain/entity/register_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository{
  Future<Either<Failure,AuthResultsEntity>> login(LoginEntity login);
  Future<Either<Failure,AuthResultsEntity>> register(RegisterEntity register);
  Future<Either<Failure,AuthResultsEntity>> refreshToken(RefreshTokenEntity refreshToken);
  Future<Either<Failure,AuthResultsEntity>> confirmEmail(AuthUserCodeModel code);
  Future<Either<Failure,AuthResultsEntity>> confirmPhonenumber(AuthUserCodeModel code);
  Future<Either<Failure,void>> forgotPassword(String username);
  Future<Either<Failure,void>> confirmForgotPassword(ForgotPasswordEntity forgotPassword);
  Future<Either<Failure,void>> resendOtp(bool isEmail);
  Future<Either<Failure,bool>> isAuthenticated();
  Future<Either<Failure,void>> logout();
}