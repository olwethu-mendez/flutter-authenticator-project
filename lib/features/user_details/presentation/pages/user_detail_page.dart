import 'package:authentipass/features/auth/presentation/pages/splash_page.dart';
import 'package:authentipass/features/user_details/domain/entities/get_user_entity.dart';
import 'package:authentipass/features/user_details/presentation/bloc/user_details_bloc.dart';
import 'package:authentipass/features/user_details/presentation/bloc/user_details_event.dart';
import 'package:authentipass/features/user_details/presentation/bloc/user_details_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserDetailPage extends StatefulWidget {
  final String userId;
  const UserDetailPage({super.key, required this.userId});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  // We no longer need the userName variable or setState

  @override
  void initState() {
    super.initState();
    context.read<UserDetailsBloc>().add(
          UserDetailsRequested(userId: widget.userId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserDetailsBloc, UserDetailsState>(
      builder: (context, state) {
        // 1. Determine the Title based on state
        String title = "User Details";
        if (state is UserDetailsLoaded) {
          title = "${state.user.firstName} ${state.user.lastName}'s Details";
        }

        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, UserDetailsState state) {
    if (state is UserDetailsLoading) {
      return const SplashPage();
    }

    if (state is UserDetailsLoaded) {
      final user = state.user;
      final bool isBanned = user.isDeactivatedByAdmin ?? false;

      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _UserAvatarLarge(user: user),
            const SizedBox(height: 16),
            Text(
              "${user.firstName} ${user.lastName}",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(height: 40),
            if (user.emailAddress != null)
              _buildInfoRow(icon: Icons.email, label: "Email", value: user.emailAddress!, isVerified: user.emailConfirmed),
            if (user.phoneNumber != null)
              _buildInfoRow(icon: Icons.phone, label: "Phone", value: user.phoneNumber!, isVerified: user.phoneNumberConfirmed),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: "Joined",
              value: user.createdAt.toString().split(' ')[0],
            ),
            const Spacer(),
            _DeactivateButton(
              isBanned: isBanned,
              onPressed: () => _confirmDeactivation(context, user.userId!, isBanned),
            ),
          ],
        ),
      );
    }

    if (state is UserDetailsError) {
      return Center(child: Text(state.message));
    }

    // Fallback for Initial or unexpected states
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("User not found"),
          TextButton.icon(
            onPressed: () => context.read<UserDetailsBloc>().add(
                  UserDetailsRequested(userId: widget.userId),
                ),
            label: const Text("Retry"),
            icon: const Icon(Icons.rotate_left),
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value, bool? isVerified}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
          if (isVerified != null)
            const Spacer(),
          if (isVerified != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(
                isVerified ? Icons.verified : Icons.error_outline,
                size: 18,
                color: isVerified ? Colors.green : Colors.red,
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDeactivation(BuildContext context, String id, bool isBanned) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isBanned ? "Reactivate User?" : "Deactivate User?"),
        content: Text(
          "Are you sure you want to ${isBanned ? 'restore' : 'suspend'} this user's access?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Trigger action
              context.read<UserDetailsBloc>().add(
                    AdminDeactivatesUserRequested(userId: id),
                  );
              // Note: Usually the Bloc handles refreshing the user data 
              // automatically after a success state is reached.
            },
            child: Text(
              isBanned ? "Reactivate" : "Deactivate",
              style: TextStyle(color: isBanned ? Colors.green : Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Sub-widgets for cleaner build method
class _UserAvatarLarge extends StatelessWidget {
  final GetUserEntity user;
  const _UserAvatarLarge({required this.user});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 50,
      backgroundImage: user.profilePictureUrl != null
          ? NetworkImage(user.profilePictureUrl!)
          : null,
      child: user.profilePictureUrl == null
          ? Text("${user.firstName![0]}${user.lastName![0]}".toUpperCase(), 
                 style: const TextStyle(fontSize: 24))
          : null,
    );
  }
}

class _DeactivateButton extends StatelessWidget {
  final bool isBanned;
  final VoidCallback onPressed;
  const _DeactivateButton({required this.isBanned, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(isBanned ? Icons.settings_backup_restore : Icons.block),
        label: Text(isBanned ? "REACTIVATE USER" : "DEACTIVATE USER"),
        style: ElevatedButton.styleFrom(
          backgroundColor: isBanned ? Colors.green : Colors.red,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}