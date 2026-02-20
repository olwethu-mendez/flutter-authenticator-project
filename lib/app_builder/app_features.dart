import 'package:authentipass/features/auth/presentation/pages/banned_page.dart';
import 'package:authentipass/features/auth/presentation/pages/login_page.dart';
import 'package:authentipass/features/auth/presentation/pages/otp_page.dart';
import 'package:authentipass/features/profile/presentation/pages/change_email_page.dart';
import 'package:authentipass/features/profile/presentation/pages/change_password_page.dart';
import 'package:authentipass/features/profile/presentation/pages/change_phone_number_page.dart';
import 'package:authentipass/features/profile/presentation/pages/deactivate_profile_page.dart';
import 'package:authentipass/features/profile/presentation/pages/profile_manager.dart';
import 'package:authentipass/features/profile/presentation/pages/reactivate_page.dart';
import 'package:authentipass/features/auth/presentation/pages/register_page.dart';
import 'package:authentipass/features/auth/presentation/pages/splash_page.dart';
import 'package:authentipass/features/home_layout/presentation/pages/home_layout.dart';
import 'package:authentipass/features/profile/data/models/user_profile_model.dart';
import 'package:authentipass/features/profile/presentation/pages/create_profile_page.dart';
import 'package:authentipass/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:authentipass/features/settings/presentation/pages/settings_page.dart';
import 'package:authentipass/features/settings/presentation/pages/theme_settings_page.dart';
import 'package:authentipass/features/user_details/presentation/pages/user_detail_page.dart';
import 'package:authentipass/features/users_management/presentation/pages/user_management_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class AppFeatures {
  static final List<AppFeature> features = [
    AppFeature(
      name: "Authentication",
      routes: [
        AppRoute(
          name: 'splash',
          path: '/', 
          builder: (context, state) => const SplashPage(),
        ),
        AppRoute(
          name: 'register',
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        AppRoute(
          name: 'login',
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
            // ADD THESE:
        AppRoute(
          name: 'verify-email',
          path: '/verify-otp/email',
          builder: (context, state) {
            final comType = state.uri.queryParameters['com-type']; // Use uri.queryParameters
            final username = state.uri.queryParameters['username'];
            return OtpPage(otpType: OtpType.verifyEmail, comType: comType, username: username);
          }
        ),
        AppRoute(
          name: 'verify-phone', 
          path: '/verify-otp/phone',
          builder: (context, state) { 
            final comType = state.uri.queryParameters['com-type']; // Use uri.queryParameters
            final username = state.uri.queryParameters['username'];
            return OtpPage(otpType: OtpType.verifyPhone, comType: comType, username: username);
          },
        ),
        AppRoute(
          name: 'forgot-password', 
          path: '/verify-otp/forgot-password',
          builder: (context, state) {
            final comType = state.uri.queryParameters['com-type']; // Use uri.queryParameters
            final username = state.uri.queryParameters['username'];
            return OtpPage(otpType: OtpType.forgotPassword, comType: comType, username: username);
          }
        ),
        AppRoute(
          name: 'banned',
          path: '/banned',
          builder: (context, state) => const BannedPage(),
        ),
        AppRoute(
          name: 'reactivate',
          path: '/reactivate',
          builder: (context, state) => const ReactivatePage(),
        ),
      ]
    ),
    AppFeature(
      name: "Home",
      routes: [
        AppRoute(
          name: 'home', 
          path: '/home',
          builder: (context, state) => const HomeLayout(),
        ),
      ]
    ),
    AppFeature(
      name: "Profile",
      routes: [
        AppRoute(
          name: 'create-profile', 
          path: '/create-profile', 
          builder: (context, state) => const CreateProfilePage(),
        ),
        AppRoute(
          name: 'update-profile', 
          path: '/update-profile', 
          builder: (context, state) {
            if (state.extra == null || state.extra is! (UserProfileModel, bool)) {
              return const HomeLayout();
            }
            final (UserProfileModel profile, bool isDetails) = state.extra as (UserProfileModel, bool);
            return EditProfilePage(profile: profile, isDetails: isDetails);
          }
        ),
        AppRoute(
          name: 'deactivate-profile', 
          path: '/deactivate-profile', 
          builder: (context, state) => const DeactivateProfilePage(),
        ),
        AppRoute(
          name: 'profile-manager', 
          path: '/profile-manager', 
          builder: (context, state) => const ProfileManagerPage(),
        ),
        AppRoute(
          name: 'change-email', 
          path: '/change-email', 
          builder: (context, state) => const ChangeEmailPage(),
        ),
        AppRoute(
          name: 'change-phone', 
          path: '/change-phone', 
          builder: (context, state) => const ChangePhoneNumberPage(),
        ),
        AppRoute(
          name: 'change-password', 
          path: '/change-password', 
          builder: (context, state) => const ChangePasswordPage(),
        ),
      ]
    ),
    AppFeature(
      name: "Users",
      routes: [
        AppRoute(
          name: 'admin-users',
          path: '/admin/users',
          builder: (context, state) {
            final parsedData = state.extra as UsersListType? ?? UsersListType.all;
            return UserManagementPage(status: parsedData);
          },
        ),
        AppRoute(
          name: 'user-details',
          path: '/user-details/:userId',
          builder: (context, state) {
            // Now 'state' is available!
            final userId = state.pathParameters['userId']!;
            return UserDetailPage(userId: userId);
          },
        ),
      ],
    ),
    AppFeature(
      name: "Menu",
      routes: [
        AppRoute(
          name: 'settings',
          path: '/settings',
          builder: (context, state) {
            return SettingsPage();
          },
        ),
        AppRoute(
          name: 'theme-settings',
          path: '/theme-settings',
          builder: (context, state) {
            return ThemeSettingsPage();
          },
        ),
      ],
    ),
  ];

  static List<AppRoute> get allRoutes => features.expand((feature) => feature.routes).toList();
}

class AppFeature {
  final String name;
  final List<AppRoute> routes;

  const AppFeature({required this.name, required this.routes});
}

class AppRoute {
  final String name;
  final String path;
  final Widget Function(BuildContext context, GoRouterState state) builder;

  const AppRoute({required this.name, required this.path, required this.builder});
}