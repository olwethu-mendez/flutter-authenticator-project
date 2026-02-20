import 'package:authentipass/core/theme/theme_state.dart';

abstract class ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}

class ToggleHighContrastEvent extends ThemeEvent {
  final bool isHighContrast;
  final bool? isUpdatingContrast;
  ToggleHighContrastEvent({
    required this.isHighContrast,
    this.isUpdatingContrast,
  });
}

class SetThemeEvent extends ThemeEvent {
  final AppMode themeMode;
  final bool? isUpdatingMode;
  SetThemeEvent(this.themeMode, {this.isUpdatingMode});
}

class LoadThemeEvent extends ThemeEvent {}

class ResetThemeFlagsEvent extends ThemeEvent {}

// theme_event.dart
class ChangeFontSizeEvent extends ThemeEvent {
  final double fontSizeFactor;
  ChangeFontSizeEvent(this.fontSizeFactor);
}