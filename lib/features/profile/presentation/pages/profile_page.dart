import 'package:authentipass/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_event.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_state.dart';
import 'package:authentipass/features/auth/presentation/pages/splash_page.dart';
import 'package:authentipass/features/profile/data/models/user_profile_model.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_event.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_state.dart';
import 'package:authentipass/utilities/date_extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String role = "";

  @override
  void initState() {
    var authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      role = authState.role;
    }
    super.initState();
  }

Future<void> _shareProfileLink(UserProfileModel profile) async {
  // Use your actual domain here
  final String profileLink = "https://authentipass.com/user-details/${profile.userId}";
  
  await SharePlus.instance.share(
    ShareParams(
      text:"Check out ${profile.firstName}'s profile on AuthentiPass: $profileLink",
      subject: "${profile.firstName}'s Profile",
    )
  );
}

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileDeactivated) {
          context.read<AuthBloc>().add(AuthLogoutRequested());
        }
      },
      child: Scaffold(
        // Added Scaffold for proper layout
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final profile = (state is ProfileLoaded) ? state.profile : null;

            if (profile == null) return SplashPage();
            return RefreshIndicator.adaptive(
              onRefresh: () async {
                context.read<ProfileBloc>().add(FetchProfileRequested());
              },
              child: _buildProfileContent(context, profile, false)
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfileModel profile, bool isSharing) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar Stack
            Stack(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundImage: profile.profilePictureUrl != null
                      ? CachedNetworkImageProvider(profile.profilePictureUrl!)
                      : null,
                  child: profile.profilePictureUrl == null
                      ? Text(
                          "${profile.firstName![0].toUpperCase()}${profile.lastName![0].toUpperCase()}",
                          style: Theme.of(context).textTheme.headlineLarge,
                        )
                      : null,
                ),
                if(!isSharing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 18,
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () => context.push(
                        "/update-profile",
                        extra: (profile, false),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "${profile.firstName} ${profile.lastName}",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              profile.phoneNumber == profile.username ? "${profile.countryCode}${profile.username}" : profile.username ?? '',
              style: const TextStyle(color: Colors.grey),
            ),
            if(!isSharing)
            const SizedBox(height: 16),
            if(!isSharing)
            Wrap(
              alignment:
                  WrapAlignment.center, // Distributes buttons like a Spacer
              spacing: 10, // Horizontal gap between buttons
              runSpacing: 10, // Vertical gap if they wrap to a new line
              children: [
                SizedBox(
                  width: 194,
                  child: ElevatedButton.icon(
                    onPressed: () => _shareProfileLink(profile),
                    label: const Text("Share Profile"),
                    icon: const Icon(Icons.share),
                  ),
                ),
                SizedBox(
                  width: 194,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push("/update-profile", extra: (profile, true)),
                    label: const Text("Edit Profile"),
                    icon: const Icon(Icons.edit),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(height: 40),
            if (profile.emailAddress != null)
              _buildInfoTile(Icons.email, "Email", profile.emailAddress!),
            if (profile.phoneNumber != null && profile.countryCode != null)
              _buildInfoTile(Icons.phone, "Phone", "${profile.countryCode}${profile.phoneNumber}"),
            _buildInfoTile(
              Icons.wc,
              "Gender",
              (profile.gender?.toLowerCase() != "other")
                  ? profile.gender!
                  : "${profile.gender} (${profile.genderSelfDescription})",
            ),
            _buildInfoTile(
              Icons.calendar_today,
              "Member Since",
              profile.createdAt.toReadableDate(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}