import 'package:authentipass/features/profile/data/models/user_profile_model.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_event.dart'; // Ensure you have events defined
import 'package:authentipass/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileManagerPage extends StatelessWidget {
  const ProfileManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Management'),
        centerTitle: true,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated && state.preferredContactModeChanged == true) {
            context.read<ProfileBloc>().add(ResetProfileFlagsEvent());
            context.read<ProfileBloc>().add(FetchProfileRequested());            
          }
        },
        builder: (context, state) {
          if (state is! ProfileLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = state.profile;
          final String updatedTimeAgo = 
            (profile.passwordLastUpdated != null && profile.passwordLastUpdated! <= 7)
            ? profile.passwordLastUpdated! > 1 ? "${profile.passwordLastUpdated} days ago" : "1 day ago"
            :(profile.passwordLastUpdated != null && (profile.passwordLastUpdated! > 7 && profile.passwordLastUpdated! <= 30))
              ? "about ${ (profile.passwordLastUpdated! / 7).floor() > 1 ? "${(profile.passwordLastUpdated! / 7).floor()} weeks ago" : "a week ago" }"
              :(profile.passwordLastUpdated != null && (profile.passwordLastUpdated! > 30 && profile.passwordLastUpdated! <= 365))
                ? "about ${ (profile.passwordLastUpdated! / 30).floor() > 1 ? "${(profile.passwordLastUpdated! / 30).floor()} months ago" : "a month ago" }"
                :(profile.passwordLastUpdated != null && profile.passwordLastUpdated! > 365)
                  ? "over ${ (profile.passwordLastUpdated! / 365).floor() > 1 ? "${(profile.passwordLastUpdated! / 365).floor()} years ago" : "a year ago" }" : "unknown";

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _buildSectionHeader(context, 'Basic Information'),
                _buildSettingCard(
                  context,
                  child: ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Display Name'),
                    subtitle: Text("${profile.firstName} ${profile.lastName}"),
                    trailing: const Icon(Icons.edit_outlined, size: 20),
                    onTap: () => context.push("/update-profile", extra: (profile, true)),
                  ),
                ),

                _buildSectionHeader(context, 'Contact & Security'),
                _buildSettingCard(
                  context,
                  child: Column(
                    children: [
                      // Email Section
                      _buildContactTile(
                        context,
                        icon: Icons.email_outlined,
                        title: 'Email Address',
                        value: profile.emailAddress,
                        isVerified: profile.emailConfirmed ?? false, // Logical check
                        onTap: () => context.push("/change-email"),
                      ),
                      const Divider(height: 1, indent: 55),
                      
                      // Phone Section
                      _buildContactTile(
                        context,
                        icon: Icons.phone_android_outlined,
                        title: 'Phone Number',
                        value: (profile.countryCode != null && profile.phoneNumber != null) ? "${profile.countryCode}${profile.phoneNumber}" : null,
                        isVerified: profile.phoneNumberConfirmed ?? false, // Logical check
                        onTap: () => context.push("/change-phone"),
                      ),
                      const Divider(height: 1, indent: 55),

                      // Password Section (Always navigate to a secure flow)
                      ListTile(
                        leading: const Icon(Icons.lock_outline),
                        title: const Text('Change Password'),
                        subtitle: Text('Last updated $updatedTimeAgo'), // Optional metadata
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push("/change-password"),
                      ),
                    ],
                  ),
                ),

                _buildSectionHeader(context, 'Preferences'),
                _buildSettingCard(
                  context,
                  child: SwitchListTile(
                    secondary: const Icon(Icons.badge_outlined),
                    title: const Text('Primary Identity'),
                    subtitle: Text(
                      'Current: ${profile.username == profile.phoneNumber 
                          ? '${profile.countryCode}${profile.username}' 
                          : profile.username}',
                    ),
                    // 1. Fixed logic: Check if the username is currently set to the email
                    value: profile.username == profile.emailAddress,
                    
                    // 2. Fix: Use Icon objects directly for thumbIcon (Flutter 3.7+)
                    // Note: activeThumbImage/inactiveThumbImage are for actual Images.
                    // For Icons, use thumbIcon:
                    thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Icon(Icons.email, color: Theme.of(context).colorScheme.primary);
                      }
                      return Icon(Icons.phone_android, color: Colors.white);
                    }),
                    onChanged: (bool useEmail) {
                      _handlePreferenceChange(context, useEmail, profile);
                    },
                  ),
                ),

                _buildSectionHeader(context, 'Danger Zone'),
                _buildSettingCard(
                  context,
                  child: ListTile(
                    leading: const Icon(Icons.no_accounts_outlined, color: Colors.red),
                    title: const Text('Deactivate Account', style: TextStyle(color: Colors.red)),
                    onTap: () => context.push("/deactivate-profile"),
                  ),
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: Text(
                    "Switching your Primary Identity will change how you log in and where you receive security alerts.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Logic Helpers ---

  void _handlePreferenceChange(BuildContext context, bool useEmail, UserProfileModel profile) {
    final targetMode = useEmail ? 'email' : 'phone';
    final isVerified = useEmail ? profile.emailConfirmed : profile.phoneNumberConfirmed;

    if (isVerified == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please verify your $targetMode before setting it as primary.')),
      );
      return;
    } else if ( isVerified == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to determine verification status for $targetMode.')),
      );
      return;
    }

    // Trigger Bloc Event to update preferred mode/username
    context.read<ProfileBloc>().add(SetPreferredContactModeRequested(mode: targetMode));
  }

  // --- UI Components ---

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildSettingCard(BuildContext context, {required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }

  Widget _buildContactTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? value,
    required bool isVerified,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value ?? 'Tap to add'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Icon(
              isVerified ? Icons.check_circle_outline : Icons.error_outline,
              color: isVerified ? Colors.green : Colors.orange,
              size: 20,
            ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}