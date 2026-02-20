import 'package:authentipass/core/theme/theme_bloc.dart';
import 'package:authentipass/core/theme/theme_event.dart';
import 'package:authentipass/core/theme/theme_state.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_event.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_state.dart';
import 'package:authentipass/features/auth/presentation/pages/splash_page.dart';
import 'package:authentipass/features/home/presentation/pages/home_page.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_event.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_state.dart';
import 'package:authentipass/features/profile/presentation/pages/profile_page.dart';
import 'package:authentipass/features/users_management/presentation/pages/create_user_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  late int _currentIndex;
  late final PageController _pageController;

  List<Widget> get pages {
  final state = context.read<AuthBloc>().state;
  if (state is AuthAuthenticated && state.role == "Admin") {
    return [HomePage(), CreateUserPage(), ProfilePage()];
  }
  return [HomePage(), ProfilePage()];
}

List<String> get titles {
  final state = context.read<AuthBloc>().state;
  if (state is AuthAuthenticated && state.role == "Admin") {
    return ["Home", "Create User", "User Profile"];
  }
  return ["Home", "User Profile"];
}

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    // Fetch user profile when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileBloc>().add(FetchProfileRequested());
    });
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthLoading || authState is AuthUnauthenticated) {
            return const SplashPage();
          }

          // Wait for profile to load before showing home content
          return Scaffold(
            appBar: AppBar(
              title: Text(
                titles.isNotEmpty
                    ? titles[_currentIndex]
                    : "Authenticator App",
              ),
              actions: [
                IconButton(
                  onPressed: () => authState is AuthAuthenticated
                      ? _showDrawer(authState)
                      : null,
                  icon: const Icon(Icons.menu),
                ),
              ],
            ),
            body: SafeArea(
              child: BlocBuilder<ProfileBloc, ProfileState>(
                buildWhen: (prev, curr) =>
                    curr is ProfileLoaded ||
                    curr is ProfileError ||
                    curr is ProfileLoading,
                builder: (context, profileState) {
                  // 1. If we are loading and have no previous data, show splash
                  if (profileState is ProfileLoading ||
                      profileState is ProfileInitial) {
                    return const SplashPage();
                  }

                  // 2. IMPORTANT: If we are in a "transient" state (like biometric check)
                  // but the app already had a profile, don't show the splash screen.
                  // Instead, rely on the Bloc to keep the latest profile in a 'ProfileLoaded' state.
                  if (profileState is! ProfileLoaded &&
                      profileState is! ProfileError) {
                    // This catches states like BiometricAvailabilityChecked
                    // Trigger a fetch to get back to ProfileLoaded
                    context.read<ProfileBloc>().add(FetchProfileRequested());
                    return const SplashPage();
                  }
                  if (profileState is ProfileActivated) {
                    // If profile is activated, refetch the profile
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context.read<ProfileBloc>().add(FetchProfileRequested());
                    });
                    context.go('/home');
                  }

                  // Show home content once profile is loaded
                  return Column(
                    children: [
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: profileState is ProfileError ? [_profileError(context, profileState)]
                              : (profileState is ProfileLoaded)
                              ? [Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            child: pages[_currentIndex],
                          )]
                              : [],
                          onPageChanged: (index) {
                            // This keeps the internal state in sync if the controller moves
                            if (_currentIndex != index) {
                              setState(() => _currentIndex = index);
                            }
                          },
                        )
                      ),
                    ],
                  );
                },
              ),
            ),
            bottomNavigationBar: _buildBottomNavigationBar(),
          );
        },
      ),
    );
  }

  //profile error
  Widget _profileError(BuildContext context, ProfileState profileState) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load profile',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (profileState is ProfileError)
              Text(
                profileState.message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProfileBloc>().add(FetchProfileRequested());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // --- MODIFIED BottomNavigationBar METHOD ---
  Widget _buildBottomNavigationBar() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        // Show only if profile is successfully loaded
        if (profileState is ProfileError || profileState is ProfileLoading) {
          // Only hide if there's a hard error or it's the very first load
          return const SizedBox.shrink();
        }

        return BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            // Link onTap to the PageController
            _pageController.animateToPage(
              _currentIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey.shade600,
          items: titles.map((title) {
            return BottomNavigationBarItem(
              icon: Icon(
                title == "Home"
                    ? Icons.home_outlined
                    : title == "Create User"
                    ? Icons.person_add_alt_1
                    : Icons.person_outline,
              ),
              label: title,
            );
          }).toList(),
        );
      },
    );
  }

  // --- END MODIFIED BottomNavigationBar METHOD ---
  void _showDrawer(AuthAuthenticated state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDrawer(state),
    );
  }

  Widget _buildDrawer(AuthAuthenticated state) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onInverseSurface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Drawer content
          Expanded(
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, profileState) {
                final userFullName = profileState is ProfileLoaded
                    ? '${profileState.profile.firstName} ${profileState.profile.lastName}'
                    : 'User';
                final username = profileState is ProfileLoaded
                    ? profileState.profile.emailAddress ??
                          profileState.profile.phoneNumber ??
                          "user"
                    : 'User';
                final userInitials = profileState is ProfileLoaded
                    ? '${profileState.profile.firstName?[0]}${profileState.profile.lastName?[0]}'
                    : 'U';

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // User info in drawer
                    if (profileState is ProfileLoaded)
                      InkWell(
                        onTap: titles[_currentIndex] != "User Profile"
                            ? () {
                                Navigator.pop(context);
                                setState(() {
                                  _currentIndex = state.role == "Admin" ? 2 : 1;
                                });
                                // Link onTap to the PageController
                                _pageController.animateToPage(
                                  1,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              }
                            : () => context.push('/profile-manager'),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              child: Text(
                                userInitials,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userFullName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    titles[_currentIndex] == "User Profile"
                                        ? 'Tap to manage profile'
                                        : username,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black54,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (profileState is ProfileLoaded)
                      const SizedBox(height: 32),

                    // Menu items
                    if (profileState is ProfileLoaded &&
                        titles[_currentIndex] != "User Profile")
                      _buildDrawerItem(
                        context,
                        Icons.person_outline,
                        'Profile',
                        () {
                          Navigator.pop(context);

                          setState(() {
                            _currentIndex = 1;
                          });
                          // Link onTap to the PageController
                          _pageController.animateToPage(
                            1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                      ),
                    if (profileState is ProfileLoaded)
                      _buildDrawerItem(
                        context,
                        Icons.settings_outlined,
                        'Settings',
                        () {
                          Navigator.pop(context);
                          context.push('/settings');
                        },
                      ),
                    if (profileState is ProfileLoaded)
                      _buildDrawerItem(
                        context,
                        Icons.help_outline,
                        'Help & Support',
                        () {
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Help & Support feature coming soon',
                              ),
                            ),
                          );
                        },
                      ),
                    _buildDrawerItem(context, Icons.info_outline, 'About', () {
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('About feature coming soon')),
                      );
                    }),

                    BlocBuilder<ThemeBloc, ThemeState>(
                      builder: (context, state) {
                        return _buildDrawerItem(
                          context,
                          state.appMode == AppMode.light
                              ? Icons.nightlight_round
                              : state.appMode == AppMode.dark
                              ? Icons.settings_suggest_outlined
                              : Icons.wb_sunny_outlined,
                          state.appMode == AppMode.light
                              ? "Set Dark Mode"
                              : state.appMode == AppMode.dark
                              ? "Set System Mode"
                              : "Set Light Mode",
                          () {
                            context.read<ThemeBloc>().add(ToggleThemeEvent());
                          },
                        );
                      },
                    ),

                    _buildDrawerItem(context, Icons.logout, 'Logout', () {
                      Navigator.pop(context);
                      context.read<AuthBloc>().add(AuthLogoutRequested());
                    }, isLogout: true),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: isLogout ? Colors.red : null,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
