// lib/injection_container.dart

import 'package:authentipass/core/api/api_interceptor.dart';
import 'package:authentipass/core/api/app_config.dart';
import 'package:authentipass/core/api/error_interceptor.dart';
import 'package:authentipass/core/services/signalr_service.dart';
import 'package:authentipass/core/theme/theme_bloc.dart';
import 'package:authentipass/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:authentipass/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:authentipass/features/auth/data/repository/auth_repository_impl.dart';
import 'package:authentipass/features/auth/domain/repository/auth_repository.dart';
import 'package:authentipass/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:authentipass/features/auth/domain/usecases/confirm_email_usecase.dart';
import 'package:authentipass/features/profile/domain/usecases/confirm_email_usecase.dart' as pr;
import 'package:authentipass/features/auth/domain/usecases/confirm_forgot_password_usecase.dart';
import 'package:authentipass/features/auth/domain/usecases/confirm_phone_usecase.dart';
import 'package:authentipass/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:authentipass/features/auth/domain/usecases/login_usecase.dart';
import 'package:authentipass/features/auth/domain/usecases/logout_usecase.dart';
import 'package:authentipass/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:authentipass/features/auth/domain/usecases/register_usecase.dart';
import 'package:authentipass/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:authentipass/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:authentipass/features/profile/data/repository/profile_repository_impl.dart';
import 'package:authentipass/features/profile/domain/repository/profile_repository.dart';
import 'package:authentipass/features/profile/domain/usecases/activate_profile_usecase.dart';
import 'package:authentipass/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:authentipass/features/profile/domain/usecases/confirm_phone_number_usecase.dart';
import 'package:authentipass/features/profile/domain/usecases/deactivate_profile_usecase.dart';
import 'package:authentipass/features/profile/domain/usecases/create_profile_usecase.dart';
import 'package:authentipass/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:authentipass/features/profile/domain/usecases/set_preferred_contact_mode_usecase.dart';
import 'package:authentipass/features/profile/domain/usecases/update_email_usecase.dart';
import 'package:authentipass/features/profile/domain/usecases/update_phone_number_usecase.dart';
import 'package:authentipass/features/profile/domain/usecases/update_profile_picture_usecase.dart';
import 'package:authentipass/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:authentipass/features/profile/domain/usecases/verify_code_usecase.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:authentipass/features/settings/data/datasource/settings_local_datasource.dart';
import 'package:authentipass/features/settings/data/repository/settings_repository_impl.dart';
import 'package:authentipass/features/settings/domain/repository/settings_repository.dart';
import 'package:authentipass/features/settings/domain/usecases/get_biometric_settings_usecase.dart';
import 'package:authentipass/features/settings/domain/usecases/set_biometric_settings_usecase.dart';
import 'package:authentipass/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:authentipass/features/user_details/data/datasource/user_details_remote_datasource.dart';
import 'package:authentipass/features/user_details/data/repository/user_details_repository_impl.dart';
import 'package:authentipass/features/user_details/domain/repository/user_details_repository.dart';
import 'package:authentipass/features/user_details/domain/usecases/admin_deactivates_user_usecase.dart';
import 'package:authentipass/features/user_details/domain/usecases/get_single_user_usecase.dart';
import 'package:authentipass/features/user_details/presentation/bloc/user_details_bloc.dart';
import 'package:authentipass/features/users_management/data/datasource/users_remote_datasource.dart';
import 'package:authentipass/features/users_management/data/repository/users_repository_impl.dart';
import 'package:authentipass/features/users_management/domain/repository/users_repository.dart';
import 'package:authentipass/features/users_management/domain/usecases/create_users_usecase.dart';
import 'package:authentipass/features/users_management/domain/usecases/get_users_usecase.dart';
import 'package:authentipass/features/users_management/presentation/bloc/users_bloc.dart';
import 'package:authentipass/features/users_management_list_view/data/datasource/users_view_local_datasource.dart';
import 'package:authentipass/features/users_management_list_view/data/repository/users_view_repository_impl.dart';
import 'package:authentipass/features/users_management_list_view/domain/repository/users_view_repository.dart';
import 'package:authentipass/features/users_management_list_view/domain/usecases/get_view_usecase.dart';
import 'package:authentipass/features/users_management_list_view/domain/usecases/set_view_usecase.dart';
import 'package:authentipass/features/users_management_list_view/presentation/bloc/users_view_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  
  // ! Features - Auth
  
  // 1. BLOC
  // We use registerFactory because Blocs should be disposed after use. 
  // Each time we request a Bloc, we get a fresh instance.
  sl.registerFactory(
    () => AuthBloc(
      checkAuthUseCase: sl(),       // sl() automatically finds the registered CheckAuthUseCase
      loginUseCase: sl(),           // sl() finds LoginUseCases
      logoutUseCase: sl(),
      refreshTokenUseCase: sl(),
      registerUseCase: sl(),
      authLocalDataSource: sl(),
      confirmEmailUsecase: sl(),
      confirmPhoneUsecase: sl(),
      resendOtpUsecase: sl(), 
      forgotPasswordUsecase: sl(),
      confirmForgotPasswordUsecase: sl(),
      settingsLocalDataSource: sl(),
      signalRService: sl(), // Add this
    ));

  sl.registerFactory(() => ProfileBloc(
    createProfileUseCase: sl(),
    getProfileUseCase: sl(),
    updateProfilePictureUseCase: sl(),
    updateProfileUseCase: sl(),
    activateProfileUseCase: sl(),
    deactivateProfileUseCase: sl(), authLocalDataSource: sl(), settingsLocalDataSource: sl(),
    updateEmailUseCase: sl(),
    updatePhoneNumberUsecase: sl(),
    verifyCodeUsecase: sl(),
    changePasswordUsecase: sl(),
    setPreferredContactModeUsecase: sl(),
    confirmEmailUsecase: sl(),
    confirmPhoneNumberUsecase: sl(),
  ));
    
sl.registerFactory(() => UsersBloc(
  getUsersUsecase: sl(),
  createUserUsecase: sl(),
));

sl.registerFactory(() => UsersViewBloc(
  getViewUsecase: sl(),
  setViewUsecase: sl()
));

sl.registerFactory(() => UserDetailsBloc(
    getSingleUserUsecase: sl(),
    adminDeactivatesUserUsecase: sl(),
      signalRService: sl(), // Add this
  ),
);

sl.registerFactory(() => SettingsBloc(
    getBiometricSettingsUsecase: sl(),
    setBiometricSettingsUsecase: sl(),
  ),
);


  sl.registerFactory(() => ThemeBloc(sharedPreferences: sl()));

  // 2. USE CASES
  // We use registerLazySingleton because UseCases can be reused.
  sl.registerLazySingleton(() => CheckAuthUseCase(repository: sl()));
  sl.registerLazySingleton(() => LoginUseCases(repository: sl()));
  sl.registerLazySingleton(() => LogoutUseCase(repository: sl()));
  sl.registerLazySingleton(() => RefreshTokenUseCases(repository: sl()));
  sl.registerLazySingleton(() => RegisterUseCases(repository: sl()));
  
  sl.registerLazySingleton(() => ConfirmEmailUsecase(repository: sl()));
  sl.registerLazySingleton(() => ConfirmPhoneUsecase(repository: sl()));
  sl.registerLazySingleton(() => ResendOtpUsecase(repository: sl()));
  sl.registerLazySingleton(() => ForgotPasswordUsecase(repository: sl()));
  sl.registerLazySingleton(() => ConfirmForgotPasswordUsecase(repository: sl()));
  
  sl.registerLazySingleton(() => CreateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfilePictureUseCase(sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => ActivateProfileUseCase(sl()));
  sl.registerLazySingleton(() => DeactivateProfileUseCase(sl()));

  sl.registerLazySingleton(() => GetSingleUserUsecase(sl()));
  sl.registerLazySingleton(() => AdminDeactivatesUserUsecase(sl()));
  sl.registerLazySingleton(() => GetUsersUsecase(sl()));
  sl.registerLazySingleton(() => CreateUserUseCase(sl()));

  sl.registerLazySingleton(() => GetViewUsecase(sl()));
  sl.registerLazySingleton(() => SetViewUsecase(sl()));

  sl.registerLazySingleton(() => GetBiometricSettingsUsecase(sl()));
  sl.registerLazySingleton(() => SetBiometricSettingsUsecase(sl()));

  sl.registerLazySingleton(() => ChangePasswordUsecase(sl()));
  sl.registerLazySingleton(() => UpdateEmailUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePhoneNumberUsecase(sl()));
  sl.registerLazySingleton(() => VerifyCodeUsecase(sl()));
  sl.registerLazySingleton(() => SetPreferredContactModeUsecase(sl()));
  sl.registerLazySingleton(() => ConfirmPhoneNumberUsecase(sl()));
  sl.registerLazySingleton(() => pr.ConfirmEmailUsecase(sl()));



  // 3. REPOSITORY
  // Abstract Class -> Implementation Class
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authRemoteDataSource: sl(),
      authLocalDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<ProfileRepository>(()=>
  ProfileRepositoryImpl(
    remoteDataSource: sl(),
    localDataSource: sl(),
  ));
  

  sl.registerLazySingleton<UsersRepository>(()=>
  UsersRepositoryImpl(
    remoteDataSource: sl(),
  ));

  
  sl.registerLazySingleton<UsersViewRepository>(()=>
  UsersViewRepositoryImpl(
    localDataSource: sl(),
  ));

  

  sl.registerLazySingleton<UserDetailsRepository>(()=>
  UserDetailsRepositoryImpl(remoteDataSource: sl()));

  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(localDataSource: sl()),
  );
  

  // 4. DATA SOURCES
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      dio: sl(),
    ),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      sharedPreferences: sl(),
      secureStorage: sl(),
    ),
  );

  sl.registerLazySingleton<UsersViewLocalDataSource>(
    () => UsersViewLocalDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDatasource(
      dio: sl(),
    ),
  );

  sl.registerLazySingleton<UsersRemoteDataSource>(
    () => UsersRemoteDatasource(
      dio: sl(),
    ),
  );

  sl.registerLazySingleton<UserDetailsRemoteDataSource>(
    () => UserDetailsRemoteDatasource(dio: sl(),)
  );

  sl.registerLazySingleton<SettingsLocalDatasource>(
    () => SettingsLocalDatasourceImpl(
      sharedPreferences: sl(),
    ),
  );

  // ! External Dependencies (Third-party libraries)
  ////! Core
  // Configure Dio
  sl.registerLazySingleton(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl, // THIS is where baseUrl is called
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
      ),
    );
    
    // Add our interceptor
    dio.interceptors.addAll([
      ApiInterceptor(sl(), dio),
      ErrorInterceptor(),
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    ]);
    
    return dio;
  });

  sl.registerLazySingleton(() => SignalRService(sl()));
  
  // Shared Preferences (needs to be awaited)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Flutter Secure Storage
  sl.registerLazySingleton(() => const FlutterSecureStorage());
}