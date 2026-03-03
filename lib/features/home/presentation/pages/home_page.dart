import 'package:authentipass/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_state.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_state.dart';
import 'package:authentipass/features/users_management/presentation/bloc/users_bloc.dart';
import 'package:authentipass/features/users_management/presentation/bloc/users_event.dart';
import 'package:authentipass/features/users_management/presentation/bloc/users_state.dart';
import 'package:authentipass/features/users_management/presentation/pages/user_management_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated && state.role == "Admin") {
      context.read<UsersBloc>().add(
        GetUsersRequested(),
      ); // Placeholder while loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ProfileLoaded) {
          final profile = state.profile;
          String fullName = "${profile.firstName} ${profile.lastName}";

          // Use SingleChildScrollView to prevent overflows
          return Scaffold(
            body: RefreshIndicator.adaptive(
              onRefresh: () async {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated && authState.role == "Admin") {
                  context.read<UsersBloc>().add(GetUsersRequested()); // Placeholder while loading
                }
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome back, ",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      fullName,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 24),
                    _buildSecurityCard(context),
                    const SizedBox(height: 24),

                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        // Use ?. to safely check the role
                        if (authState is AuthAuthenticated &&
                            authState.role == "Admin") {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Admin Dashboard",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              BlocBuilder<UsersBloc, UsersState>(
                                builder: (context, usersState) {
                                  String userCount = "...";
                                  String activeUsersCount = "...";
                                  String deactivatedUsersCount = "...";
                                  String bannedUsersCount = "...";
                                  String unverifiedUsersCount = "...";
                                  String nonProfiledUsersCount = "...";

                                  // 1. Logic to extract the count if loaded
                                  if (usersState is UsersLoaded) {
                                    userCount = usersState.users.length.toString();
                                    activeUsersCount = usersState.users.where((x) =>
                                      x.isDeactivated == false && x.isDeactivatedByAdmin == false &&
                                      (x.emailConfirmed == true || x.phoneNumberConfirmed == true) &&
                                      (x.profileId != null)).toList().length.toString();
                                    deactivatedUsersCount = usersState.users.where((x) =>
                                      x.isDeactivated == true && x.isDeactivatedByAdmin == false)
                                        .toList().length.toString();
                                    bannedUsersCount = usersState.users.where(
                                      (x) => x.isDeactivatedByAdmin == true).toList().length.toString();

                                    unverifiedUsersCount = usersState.users.where(
                                          (x) => x.emailConfirmed == false && 
                                          x.phoneNumberConfirmed == false).toList().length.toString();
                                    nonProfiledUsersCount = usersState.users
                                        .where((x) => x.profileId == null)
                                        .toList()
                                        .length
                                        .toString();
                                  } else if (usersState is UsersError) {
                                    userCount = "!";
                                    activeUsersCount = "!";
                                    deactivatedUsersCount = "!";
                                    bannedUsersCount = "!";
                                    unverifiedUsersCount = "!";
                                    nonProfiledUsersCount = "!";
                                  }
                                  return GridView.count(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    children: [
                                      _buildWidgetCard(
                                        context,
                                        icon: Icons.people,
                                        title: userCount, // Now a safe String
                                        content: "All System Users",
                                        isGrid: false,
                                        onPressed: () {
                                          // Option A: Navigate to management page
                                          context.push(
                                            '/admin/users',
                                            extra: UsersListType.all,
                                          );
                                          // Option B: Just refresh the count
                                          context.read<UsersBloc>().add(
                                            GetUsersRequested(),
                                          );
                                        },
                                      ),
                                      _buildWidgetCard(
                                        context,
                                        icon: Icons.how_to_reg,
                                        title: activeUsersCount,
                                        content: "Active Users",
                                        isGrid: false,
                                        onPressed: () {
                                          // Option A: Navigate to management page
                                          context.push(
                                            '/admin/users',
                                            extra: UsersListType.active,
                                          );
                                          // Option B: Just refresh the count
                                          context.read<UsersBloc>().add(
                                            GetUsersRequested(),
                                          );
                                        },
                                        color: Colors.green,
                                      ),
                                      _buildWidgetCard(
                                        context,
                                        icon: Icons.block_flipped,
                                        title: deactivatedUsersCount,
                                        content: "Deactivated",
                                        isGrid: true,
                                        onPressed: () {
                                          // Option A: Navigate to management page
                                          context.push(
                                            '/admin/users',
                                            extra: UsersListType.deactivated,
                                          );
                                          // Option B: Just refresh the count
                                          context.read<UsersBloc>().add(
                                            GetUsersRequested(),
                                          );
                                        },
                                        color: Colors.red,
                                      ),
                                      _buildWidgetCard(
                                        context,
                                        icon: Icons.dangerous,
                                        title: bannedUsersCount,
                                        content: "Banned",
                                        isGrid: true,
                                        onPressed: () {
                                          // Option A: Navigate to management page
                                          context.push(
                                            '/admin/users',
                                            extra: UsersListType.banned,
                                          );
                                          // Option B: Just refresh the count
                                          context.read<UsersBloc>().add(
                                            GetUsersRequested(),
                                          );
                                        },
                                        color: Colors.red,
                                      ),
                                      _buildWidgetCard(
                                        context,
                                        icon: Icons.pending,
                                        title: unverifiedUsersCount,
                                        content: "Unverified Users",
                                        isGrid: true,
                                        onPressed: () {
                                          // Option A: Navigate to management page
                                          context.push(
                                            '/admin/users',
                                            extra: UsersListType.unverified,
                                          );
                                          // Option B: Just refresh the count
                                          context.read<UsersBloc>().add(
                                            GetUsersRequested(),
                                          );
                                        },
                                        color: Colors.orangeAccent,
                                      ),
                                      _buildWidgetCard(
                                        context,
                                        icon: Icons.no_accounts,
                                        title: nonProfiledUsersCount,
                                        content: "Users with no profile",
                                        isGrid: true,
                                        onPressed: () {
                                          // Option A: Navigate to management page
                                          context.push(
                                            '/admin/users',
                                            extra: UsersListType.withoutProfile,
                                          );
                                          // Option B: Just refresh the count
                                          context.read<UsersBloc>().add(
                                            GetUsersRequested(),
                                          );
                                        },
                                        color: Colors.orangeAccent,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink(); // Hide if not admin
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const Center(child: Text("Please complete your profile."));
      },
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user_outlined, size: 40),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              "Your identity is protected with JWT & Refresh Tokens",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // Fixed buildWidgetCard to handle layout properly
  Widget _buildWidgetCard(
    BuildContext context, {
    required IconData icon,
    String? title,
    String? content,
    bool isGrid = false,
    VoidCallback? onPressed,
    Color? color,
  }) {
    return Container(
      width: isGrid ? double.minPositive : double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min, // Added
          children: [
            Icon(icon, size: 30),
            const SizedBox(width: 8),
            Flexible(
              // Use Flexible instead of Expanded
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (content != null)
                    Text(
                      content,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
