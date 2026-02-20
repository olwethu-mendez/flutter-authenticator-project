import 'package:authentipass/core/error/exceptions.dart';
import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:authentipass/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:authentipass/features/auth/data/models/auth_user_code_model.dart';
import 'package:authentipass/features/auth/data/models/forgot_password_model.dart';
import 'package:authentipass/features/auth/data/models/login_model.dart';
import 'package:authentipass/features/auth/data/models/refresh_token_model.dart';
import 'package:authentipass/features/auth/data/models/register_model.dart';
import 'package:authentipass/features/auth/domain/entity/auth_results_entity.dart';
import 'package:authentipass/features/auth/domain/entity/forgot_password_entity.dart';
import 'package:authentipass/features/auth/domain/entity/login_entity.dart';
import 'package:authentipass/features/auth/domain/entity/refresh_token_entity.dart';
import 'package:authentipass/features/auth/domain/entity/register_entity.dart';
import 'package:authentipass/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final AuthLocalDataSource authLocalDataSource;

  AuthRepositoryImpl({
    required this.authRemoteDataSource,
    required this.authLocalDataSource,
  });

  @override
  Future<Either<Failure, AuthResultsEntity>> login(
    LoginEntity loginEntity,
  ) async {
    try {
      final loginModel = LoginModel(
        countryCode: loginEntity.countryCode,
        username: loginEntity.username,
        password: loginEntity.password,
        stayLoggedIn: loginEntity.stayLoggedIn,
      );

      final response = await authRemoteDataSource.login(loginModel);
      if (response.token != null) {
        await authLocalDataSource.cacheToken(response.token!);
      }
      if (response.refreshToken != null) {
        await authLocalDataSource.cacheRefreshToken(response.refreshToken!);
      }
      return Right(response);
    } on InvalidRequestException catch (e) {
      return Left(InvalidRequestFailure(e.message ?? "Invalid request"));
    } on InvalidCredentialsExceptions catch (e) {
      return Left(
        InvalidCredentialsFailure(
          e.message ?? "Invalid credentials or unauthorized",
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? "Server error"));
    }
  }

  @override
  Future<Either<Failure, AuthResultsEntity>> register(
    RegisterEntity registerEntity,
  ) async {
    try {
      final registerModel = RegisterModel(
        email: registerEntity.email,
        countryCode: registerEntity.countryCode,
        phoneNumber: registerEntity.phoneNumber,
        prefersEmail: registerEntity.prefersEmail,
        password: registerEntity.password,
        confirmPassword: registerEntity.confirmPassword,
      );
      final response = await authRemoteDataSource.register(
        registerModel,
      ); // Cache Tokens
      if (response.token != null) {
        await authLocalDataSource.cacheToken(response.token!);
      }
      return Right(response);
    } on InvalidRequestException catch (e) {
      return Left(InvalidRequestFailure(e.message ?? "Invalid request"));
    } on InvalidCredentialsExceptions catch (e) {
      return Left(
        InvalidCredentialsFailure(
          e.message ?? "Invalid credentials or unauthorized",
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? "Server error"));
    }
  }

  @override
  Future<Either<Failure, AuthResultsEntity>> refreshToken(
    RefreshTokenEntity refreshTokenEntity,
  ) async {
    try {
      final refreshTokenModel = RefreshTokenModel(
        token: refreshTokenEntity.token,
        refreshToken: refreshTokenEntity.refreshToken,
      );

      final response = await authRemoteDataSource.refreshToken(
        refreshTokenModel,
      );
      await authLocalDataSource.clearToken();
      if (response.token != null) {
        await authLocalDataSource.cacheToken(response.token!);
      }
      if (response.refreshToken != null) {
        await authLocalDataSource.cacheRefreshToken(response.refreshToken!);
      }
      return Right(response);
    } on InvalidRequestException catch (e) {
      return Left(InvalidRequestFailure(e.message ?? "Invalid request"));
    } on InvalidCredentialsExceptions catch (e) {
      return Left(
        InvalidCredentialsFailure(
          e.message ?? "Invalid credentials or unauthorized",
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? "Server error"));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
try {
    final token = await authLocalDataSource.getCachedToken();
    if (token == null) return const Right(false);
    final isAuth = await authRemoteDataSource.isAuthenticated();
    
    return Right(isAuth);
  } catch (e) {
    return const Right(false);
  }
  }

@override
Future<Either<Failure, void>> logout() async {
  try {
    // 1. Try to notify the backend
    try {
      await authRemoteDataSource.logout();
    } on InvalidCredentialsExceptions {
      print("Remote logout: Token already invalid. Proceeding to local cleanup.");
    } on ServerException {
      print("Remote logout: Server unreachable. Proceeding to local cleanup.");
    } catch (e) {
      print("Remote logout: Unexpected error $e. Proceeding to local cleanup.");
    }
    await authLocalDataSource.clearToken(); 

    return const Right(null);
  } catch (e) {
    // This only triggers if the LOCAL disk/secure storage fails
    return Left(CacheFailure("Could not clear local session."));
  }
}

@override
Future<Either<Failure, void>> resendOtp(bool isEmail) async {
    try {
      await authRemoteDataSource.resendOtp(isEmail);
      return Right(null);
    } on InvalidRequestException catch (e) {
    // PASS THE MESSAGE HERE
      return Left(InvalidRequestFailure(e.message ?? "Failed to resend code"));
    } on InvalidCredentialsExceptions catch (e) {
      return Left(InvalidCredentialsFailure(e.message ?? "Session expired"));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? "Server connection failed"));
    } catch (e) {
      // Catch-all for unexpected local errors
      return Left(ServerFailure("An unexpected error occurred: $e"));
    }
}

  @override
  Future<Either<Failure, AuthResultsEntity>> confirmEmail(AuthUserCodeModel code) async {
    try {
      final response = await authRemoteDataSource.confirmEmail(code);
      // 3. CACHE the Tokens (Critical Step!)
      if (response.token != null) {
        await authLocalDataSource.cacheToken(response.token!);
      }
      if (response.refreshToken != null) {
        await authLocalDataSource.cacheRefreshToken(response.refreshToken!);
      }
      return Right(response);
    } on InvalidRequestException catch (e) {
    // PASS THE MESSAGE HERE
      return Left(InvalidRequestFailure(e.message ?? "Invalid verification code"));
    } on InvalidCredentialsExceptions catch (e) {
      return Left(InvalidCredentialsFailure(e.message ?? "Session expired"));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? "Server connection failed"));
    } catch (e) {
      // Catch-all for unexpected local errors
      return Left(ServerFailure("An unexpected error occurred: $e"));
    }
  }

  @override
  Future<Either<Failure, AuthResultsEntity>> confirmPhonenumber(AuthUserCodeModel code) async {
    try {
      final response = await authRemoteDataSource.confirmPhonenumber(code);
      // 3. CACHE the Tokens (Critical Step!)
      if (response.token != null) {
        await authLocalDataSource.cacheToken(response.token!);
      }
      if (response.refreshToken != null) {
        await authLocalDataSource.cacheRefreshToken(response.refreshToken!);
      }
      return Right(response);
    } on InvalidRequestException catch (e) {
    // PASS THE MESSAGE HERE
      return Left(InvalidRequestFailure(e.message ?? "Invalid verification code"));
    } on InvalidCredentialsExceptions catch (e) {
      return Left(InvalidCredentialsFailure(e.message ?? "Session expired"));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? "Server connection failed"));
    } catch (e) {
      // Catch-all for unexpected local errors
      return Left(ServerFailure("An unexpected error occurred: $e"));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String username) async {
    try {
      await authRemoteDataSource.forgotPassword(username);
      return Right(null);
    } on InvalidRequestException catch (e) {
    // PASS THE MESSAGE HERE
      return Left(InvalidRequestFailure(e.message ?? "Failed to reset password"));
    } on InvalidCredentialsExceptions catch (e) {
      return Left(InvalidCredentialsFailure(e.message ?? "Session expired"));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? "Server connection failed"));
    } catch (e) {
      // Catch-all for unexpected local errors
      return Left(ServerFailure("An unexpected error occurred: $e"));
    }
  }

  @override
  Future<Either<Failure, void>> confirmForgotPassword(ForgotPasswordEntity forgotPassword) async {
    try {

      final forgotPasswordModel = ForgotPasswordModel(
        newPassword: forgotPassword.newPassword, 
        code: forgotPassword.code, 
        username: forgotPassword.username
      );
      await authRemoteDataSource.confirmForgotPassword(forgotPasswordModel);
      return Right(null);
    } on InvalidRequestException catch (e) {
    // PASS THE MESSAGE HERE
      return Left(InvalidRequestFailure(e.message ?? "Failed to reset password"));
    } on InvalidCredentialsExceptions catch (e) {
      return Left(InvalidCredentialsFailure(e.message ?? "Session expired"));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? "Server connection failed"));
    } catch (e) {
      // Catch-all for unexpected local errors
      return Left(ServerFailure("An unexpected error occurred: $e"));
    }
  }
}