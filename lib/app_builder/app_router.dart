import 'dart:async';

import 'package:authentipass/app_builder/app_features.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_event.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

// This class converts our BLoC stream into a Listenable that GoRouter understands
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthBloc authBloc, RouteObserver observer) {
    return GoRouter(
      observers: [observer],
      navigatorKey: navigatorKey,
      initialLocation: '/',

      // VERY IMPORTANT: This makes the router re-evaluate when AuthBloc changes
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final String location = state.matchedLocation;

        final bool isLoggingIn = location == '/login';
        final bool isRegistering = location == '/register';
        final bool isOnSplash = location == '/';

        // 1. ALLOW INITIALIZATION
        // If we are in Initial/Loading, ONLY return null if we are already on the Splash screen.
        // This allows the SplashPage to do its work without being interrupted.
        if (authState is AuthInitial/* || authState is AuthLoading*/) {
          return isOnSplash ? null : '/';
        }

        // 2. Handle Unauthenticated users (and Errors)
        // If the check finishes and they aren't logged in, FORCE them to login
        // unless they are already on an auth page.
        if (authState is AuthUnauthenticated ||
            authState is AuthError ||
            authState is AuthPasswordReset) {
          // If reset is successful, force login
          if (authState is AuthPasswordReset) return '/login';

          if (isLoggingIn || isRegistering) return null;
          return '/login';
        }

        if (authState is AuthForgotPasswordOtp) {
          // Use .startsWith to check the path only
          if (!location.startsWith('/verify-otp/forgot-password')) {
            // You'll need to decide how to recover the username/type if they aren't in the state,
            // but usually, you just allow the current location if it's already the OTP page.
            return '/verify-otp/forgot-password';
          }
        }
        if (authState is AuthConfirmForgotPasswordRequested) {
          return '/login';
        }

        // 3. Handle Authenticated users
        if (authState is AuthAuthenticated) {
          // Priority A: Admin Bans
          if (authState.isDeactivatedByAdmin) return '/banned';
          if (authState.isDeactivated) return '/reactivate';

          // Priority B: OTP Verification
          if (!authState.isActivated) {
            final String user = authState.username; // Adjust based on your AuthState fields
            final String com = authState.preferredCommunication;

            if (com == "email" && location != '/verify-otp/email') {
              // Append parameters to the URL string
              return '/verify-otp/email?com-type=$com&username=$user';
            }
            
            if (com == "phone" && location != '/verify-otp/phone') {
              return '/verify-otp/phone?com-type=$com&username=$user';
            }
            if (location.startsWith('/verify-otp')) return null;
          }

          // Priority C: Profile Creation
          if (!authState.hasProfile) {
            if (location != '/create-profile') return '/create-profile';
            return null;
          }

          // Priority D: If fully verified but sitting on Splash/Login/Register, go Home
          if (isLoggingIn || isRegistering || isOnSplash) {
            return '/home';
          }
        }

        return null;
      },
      routes: AppFeatures.allRoutes
          .map(
            (route) => GoRoute(
              name: route.name,
              path: route.path,
              builder: (context, state) => route.builder(context, state),
            ),
          )
          .toList(),
    );
  }
}
