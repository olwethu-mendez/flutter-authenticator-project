import 'package:authentipass/core/theme/theme_bloc.dart';
import 'package:authentipass/core/theme/theme_event.dart';
import 'package:authentipass/core/theme/theme_state.dart';
import 'package:authentipass/features/profile/data/models/user_profile_model.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:authentipass/features/profile/presentation/bloc/profile_state.dart';
import 'package:authentipass/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:authentipass/features/settings/presentation/bloc/settings_event.dart';
import 'package:authentipass/features/settings/presentation/bloc/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserProfileModel? profile;
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(GetBiometricSettingsRequested());

    final profileState = context.read<ProfileBloc>().state;
    profile = (profileState is ProfileLoaded) ? profileState.profile : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (prev, curr) =>
            (curr is SettingsStatus && !curr.isUpdate) || curr is SettingsLoading,
        builder: (context, state) {
          bool isBioEnabled = false;
          bool isLoading = state is SettingsLoading;

          if (state is SettingsStatus) {
            isBioEnabled = state.bioAuthEnabled;
          }

          return ListView(
            children: [
              _buildSectionHeader('Security'),
              _buildSettingCard(
                child: SwitchListTile.adaptive(
                  secondary: const Icon(Icons.fingerprint),
                  title: const Text('Biometric Login'),
                  subtitle: const Text('Use fingerprint or face ID to unlock'),
                  value: isBioEnabled,
                  onChanged: isLoading
                      ? null
                      : (value) {
                          context.read<SettingsBloc>().add(
                            SetBiometricSettingsRequested(enabling: value),
                          );
                        },
                ),
              ),
              _buildSectionHeader('Accessibility'),
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, themeState) {
                  return Column(
                    children: [
                      _buildSettingCard(
                        child: SwitchListTile.adaptive(
                          secondary: const Icon(Icons.contrast),
                          title: const Text('High Contrast'),
                          subtitle: const Text(
                            'Increase visibility of text and icons',
                          ),
                          value:
                              themeState.isHighContrast, // Uses correct state
                          onChanged: (val) => context.read<ThemeBloc>().add(
                            ToggleHighContrastEvent(isHighContrast: val, isUpdatingContrast: true),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, themeState) {
                  return Column(
                    children: [
                      _buildSettingCard(
                        child: SwitchListTile.adaptive(
                          secondary: const Icon(Icons.contrast),
                          title: const Text('High Contrast'),
                          subtitle: const Text(
                            'Increase visibility of text and icons',
                          ),
                          value:
                              themeState.isHighContrast, // Uses correct state
                          onChanged: (val) => context.read<ThemeBloc>().add(
                            ToggleHighContrastEvent(isHighContrast: val, isUpdatingContrast: true),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              _buildSectionHeader('Account'),
              _buildSettingCard(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    if (profile == null) return;
                    context.push("/update-profile", extra: (profile, true));
                  },
                ),
              ),
              _buildSettingCard(
                child: ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Update Profile Picture'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    if (profile == null) return;
                    context.push("/update-profile", extra: (profile, false));
                  },
                ),
              ),
              _buildSectionHeader('App Customization'),
              _buildSettingCard(
                child: ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Appearance'),
                  subtitle: const Text('Theme settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push("/theme-settings"),
                ),
              ),
            ],
          );
        
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingCard({required Widget child}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: child,
    );
  }
}
