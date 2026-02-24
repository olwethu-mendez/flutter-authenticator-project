import 'package:authentipass/app_builder/app_router.dart';
import 'package:authentipass/core/theme/theme_bloc.dart';
import 'package:authentipass/core/theme/theme_event.dart';
import 'package:authentipass/core/theme/theme_state.dart';
import 'package:authentipass/dependency_injection.dart' as di;
import 'package:authentipass/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_event.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_state.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_state.dart';
import 'package:authentipass/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:authentipass/features/settings/presentation/bloc/settings_event.dart';
import 'package:authentipass/features/settings/presentation/bloc/settings_state.dart';
import 'package:authentipass/features/user_details/presentation/bloc/user_details_bloc.dart';
import 'package:authentipass/features/user_details/presentation/bloc/user_details_state.dart';
import 'package:authentipass/features/users_management/presentation/bloc/users_bloc.dart';
import 'package:authentipass/features/users_management/presentation/bloc/users_state.dart';
import 'package:authentipass/features/users_management_list_view/presentation/bloc/users_view_bloc.dart';
import 'package:authentipass/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AuthenticatorApp extends StatefulWidget {
  const AuthenticatorApp({super.key});

  @override
  State<AuthenticatorApp> createState() => _AuthenticatorAppState();
}

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class _AuthenticatorAppState extends State<AuthenticatorApp> {
  late GoRouter _router;
  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    // Get the bloc instance
    _authBloc = di.sl<AuthBloc>();
    // Initialize the router with the bloc
    _router = AppRouter.createRouter(_authBloc, routeObserver);
    // Trigger the initial check
    _authBloc.add(AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    // Provide the AuthBloc to the entire app
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<ThemeBloc>()),
        BlocProvider.value(
          value: _authBloc,
        ), // Use .value since it's already created
        BlocProvider(create: (_) => di.sl<ProfileBloc>()),
        BlocProvider(create: (_) => di.sl<UsersBloc>()),
        BlocProvider(create: (_) => di.sl<UsersViewBloc>()),
        BlocProvider(create: (_) => di.sl<UserDetailsBloc>()),
        BlocProvider(create: (_) => di.sl<SettingsBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'Authenticator Project',
            theme: AppTheme.lightMode,
            darkTheme: AppTheme.darkMode,
            themeMode: themeState.appMode == AppMode.dark
                ? ThemeMode.dark
                : themeState.appMode == AppMode.light
                ? ThemeMode.light
                : ThemeMode.system,
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(themeState.fontSizeFactor),
                ),
                child: MultiBlocListener(
                  listeners: [
                    // 1. Auth Errors
                    BlocListener<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is AuthError) {
                          _showGlobalSnackBar(
                            context,
                            state.message,
                            Colors.red,
                          );
                          
                        } else if(state is AuthUnauthenticated && state.message != null){
                          _showGlobalSnackBar(
                            context,
                            state.message!,
                            Colors.red,
                          );                            
                          }else if (state is AuthPasswordReset) {
                          _showGlobalSnackBar(
                            context,
                            "Password reset successfully! Please login.",
                            Colors.green,
                          );
                        }
                      },
                    ),
                    // 2. Profile Errors (The feature you asked about)
                    BlocListener<ProfileBloc, ProfileState>(
                      listener: (context, state) {
                        if (state is ProfileError) {
                          _showGlobalSnackBar(
                            context,
                            state.message,
                            Colors.orange,
                          );
                        } else if (state is ProfileCreated) {
                          _showGlobalSnackBar(
                            context,
                            "Account updated and profile created successfully!",
                            Colors.green,
                          );
                        } else if (state is ProfileActivated) {
                          _showGlobalSnackBar(
                            context,
                            "Account reactivated successfully.",
                            Colors.green,
                          );
                        } else if (state is ProfileUpdated) {
                          if (state.emailConfirmed == true) {
                            _showGlobalSnackBar(
                              context,
                              "Email address verified successfully. You can now use it to login and for MFA.",
                              Colors.green,
                            );
                          } else if (state.phoneConfirmed == true) {
                            _showGlobalSnackBar(
                              context,
                              "Phone number verified successfully. You can now use it to login and for MFA.",
                              Colors.green,
                            );
                          }
                          else if (state.passwordChanged == true) {
                            _showGlobalSnackBar(
                              context,
                              "Password updated successfully.",
                              Colors.green,
                            );
                          } else if (state.phoneChanged == true) {
                            _showGlobalSnackBar(
                              context,
                              "Phone number updated successfully. Please verify the new number.",
                              Colors.green,
                            );
                          } else if (state.emailChanged == true) {
                            _showGlobalSnackBar(
                              context,
                              "Email address updated successfully. Please verify the new address.",
                              Colors.green,
                            );
                          } else if (state.profileInfoChanged == true) {
                            _showGlobalSnackBar(
                              context,
                              "Profile updated successfully.",
                              Colors.green,
                            );
                          } else if(state.preferredContactModeChanged == true){
                            _showGlobalSnackBar(
                              context,
                              "Preferred contact mode updated successfully.",
                              Colors.green,
                            );
                          }
                        } else if (state is ProfilePictureUpdated) {
                          _showGlobalSnackBar(
                            context,
                            "Profile image updated successfully.",
                            Colors.green,
                          );
                        } else if (state is ProfileDeactivated) {
                          _showGlobalSnackBar(
                            context,
                            "Profile deactivated successfully",
                            Colors.orange,
                          );
                        }
                      },
                    ),
                    // 3. User Management Error
                    BlocListener<UsersBloc, UsersState>(
                      listener: (context, state) {
                        if (state is UsersError) {
                          _showGlobalSnackBar(
                            context,
                            state.message,
                            Colors.orange,
                          );
                        }
                      },
                    ),
                    // 4. User Details Error
                    BlocListener<UserDetailsBloc, UserDetailsState>(
                      listener: (context, state) {
                        if (state is UserDetailsError) {
                          _showGlobalSnackBar(
                            context,
                            state.message,
                            Colors.orange,
                          );
                        } else if (state is UserActivated) {
                          _showGlobalSnackBar(
                            context,
                            "User Unbanned!",
                            Colors.green,
                          );
                        } else if (state is UserDeactivated) {
                          _showGlobalSnackBar(
                            context,
                            "User Banned!",
                            Colors.green,
                          );
                        }
                      },
                    ),
                    // 4. Settings Error
                    BlocListener<SettingsBloc, SettingsState>(
                      listener: (context, state) {
                        if (state is SettingsError) {
                          _showGlobalSnackBar(
                            context,
                            state.message,
                            Colors.orange,
                          );
                        } else if (state is SettingsStatus && state.isUpdate) {
                          _showGlobalSnackBar(
                            context,
                            "Biometric authentication ${state.bioAuthEnabled ? 'enabled' : 'disabled'}.",
                            Colors.green,
                          );
                          context.read<SettingsBloc>().add(
                            ResetSettingsFlagsEvent(),
                          );
                        }
                      },
                    ),
                    BlocListener<ThemeBloc, ThemeState>(
                      listener: (context, state) {
                        if (state.isUpdatingMode) {
                          String message = state.appMode == AppMode.dark
                              ? "Dark mode enabled."
                              : state.appMode == AppMode.light
                              ? "Light mode enabled."
                              : "System mode enabled.";
                          _showGlobalSnackBar(context, message, null);
                          // Reset the flag immediately
                          context.read<ThemeBloc>().add(ResetThemeFlagsEvent());
                        }

                        if (state.isUpdatingContrast) {
                          _showGlobalSnackBar(
                            context,
                            state.isHighContrast
                                ? "High contrast enabled."
                                : "High contrast disabled.",
                            null,
                          );
                          // Reset the flag immediately
                          context.read<ThemeBloc>().add(ResetThemeFlagsEvent());
                        }
                      },
                    ),
                  ],
                  child:
                      child!, // This 'child' is the current page from GoRouter
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showGlobalSnackBar(BuildContext context, String message, Color? color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
