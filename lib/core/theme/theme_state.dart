enum AppMode { light, dark, system }

class ThemeState {
  final AppMode appMode;
  final bool isHighContrast;
  final double fontSizeFactor; // New field
  final bool isUpdatingMode;
  final bool isUpdatingContrast;

  // Set default to false so it is never null
  ThemeState({
    required this.appMode,
    this.isHighContrast = false,
    this.fontSizeFactor = 1.0,
    this.isUpdatingMode = false,
    this.isUpdatingContrast = false,
  });

  ThemeState copyWith({AppMode? appMode, bool? isHighContrast, double? fontSizeFactor, bool? isUpdatingMode, bool? isUpdatingContrast}) {
    return ThemeState(
      appMode: appMode ?? this.appMode,
      isHighContrast: isHighContrast ?? this.isHighContrast,
      fontSizeFactor: fontSizeFactor ?? this.fontSizeFactor,
      isUpdatingMode: isUpdatingMode ?? this.isUpdatingMode,
      isUpdatingContrast: isUpdatingContrast ?? this.isUpdatingContrast,
    );
  }
}