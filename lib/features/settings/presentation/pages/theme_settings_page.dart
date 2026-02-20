import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:authentipass/core/theme/theme_bloc.dart';
import 'package:authentipass/core/theme/theme_event.dart';
import 'package:authentipass/core/theme/theme_state.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        centerTitle: true,
      ),
      body: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  "THEME MODE",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ),
              
              // Light Mode Option
              _ThemeOptionTile(
                title: 'Light Mode',
                icon: Icons.light_mode_outlined,
                isSelected: state.appMode == AppMode.light,
                onTap: () => _updateTheme(context, state.appMode, AppMode.light),
              ),
              
              // Dark Mode Option
              _ThemeOptionTile(
                title: 'Dark Mode',
                icon: Icons.dark_mode_outlined,
                isSelected: state.appMode == AppMode.dark,
                onTap: () => _updateTheme(context, state.appMode, AppMode.dark),
              ),
              
              // System Default Option
              _ThemeOptionTile(
                title: 'System Default',
                icon: Icons.settings_brightness_outlined,
                isSelected: state.appMode == AppMode.system,
                onTap: () => _updateTheme(context, state.appMode, AppMode.system),
              ),
              
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "System default will automatically match your device's display settings.",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper logic to handle the cycling event in your Bloc
  void _updateTheme(BuildContext context, AppMode currentMode, AppMode targetMode) {
    if (currentMode == targetMode) return;
    
    // Since your ToggleThemeEvent cycles index by index:
    // We keep adding the event until the state matches the target.
    // NOTE: In a future refactor, consider adding a 'SetSpecificTheme(AppMode mode)' event.
    context.read<ThemeBloc>().add(SetThemeEvent(targetMode, isUpdatingMode: true));
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      color: isSelected 
          ? colorScheme.primaryContainer.withOpacity(0.5) 
          : colorScheme.surfaceVariant.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected 
            ? BorderSide(color: colorScheme.primary, width: 1.5)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? colorScheme.primary : null),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isSelected 
            ? Icon(Icons.check_circle, color: colorScheme.primary) 
            : const Icon(Icons.circle_outlined),
        onTap: onTap,
      ),
    );
  }
}