import 'package:flutter/material.dart';

// Using a distinct blue/indigo seed provides much better contrast range
// than using pure white/black as seeds.
var kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 33, 150, 243),
  brightness: Brightness.light,
);

var kDarkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 33, 150, 243),
  brightness: Brightness.dark,
);

class AppTheme {
  static final ThemeData darkMode = ThemeData.dark().copyWith(
    colorScheme: kDarkColorScheme,

    // High contrast AppBar: Deep surface with bright primary text
    appBarTheme: const AppBarTheme().copyWith(
      backgroundColor: kDarkColorScheme.surface,
      foregroundColor: kDarkColorScheme.onSurface,
      elevation: 0,
    ),

    // Cards: Using surfaceVariant for a subtle but distinct separation from background
    cardTheme: const CardThemeData().copyWith(
      color: kDarkColorScheme.surfaceContainerHigh, // M3 standard for cards
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kDarkColorScheme.primary,
        foregroundColor:
            kDarkColorScheme.onPrimary, // Ensures high contrast on button text
      ),
    ),
  );

  static final ThemeData lightMode = ThemeData().copyWith(
    colorScheme: kColorScheme,

    appBarTheme: const AppBarTheme().copyWith(
      backgroundColor: kColorScheme.primary,
      foregroundColor: kColorScheme.onPrimary,
      elevation: 0,
    ),

    cardTheme: const CardThemeData().copyWith(
      color: kColorScheme.surfaceContainerLowest,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1, // Subtle shadow for light mode visibility
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kColorScheme.primary,
        foregroundColor: kColorScheme.onPrimary,
      ),
    ),
  );

static ThemeData highContrastMode(bool isDark) {
  final Color primaryColor = isDark ? const Color(0xFF00FFFF) : const Color(0xFF0000FF);
  final Color onSurfaceColor = isDark ? Colors.white : Colors.black;
  final Color surfaceColor = isDark ? Colors.black : Colors.white;

  return ThemeData(
    useMaterial3: true,
    brightness: isDark ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: isDark ? Brightness.dark : Brightness.light,
      surface: surfaceColor,
      onSurface: onSurfaceColor,
      primary: primaryColor,
      onPrimary: isDark ? Colors.black : Colors.white,
      outline: onSurfaceColor, // High contrast border color
    ),
    
    // 1. Bold Text Theme for readability
    textTheme: const TextTheme().copyWith(
      displayLarge: TextStyle(fontWeight: FontWeight.bold, color: onSurfaceColor),
      bodyLarge: TextStyle(
        fontWeight: FontWeight.w700, // Thicker body text
        fontSize: 18,               // Slightly larger
        letterSpacing: 0.5,
        color: onSurfaceColor,
      ),
      bodyMedium: TextStyle(fontWeight: FontWeight.w600, color: onSurfaceColor),
    ),

    // 2. Ultra-visible Card borders
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: onSurfaceColor, width: 2.5),
        borderRadius: BorderRadius.circular(4), // Sharper corners are often easier to define
      ),
    ),

    // 3. High Contrast Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: isDark ? Colors.black : Colors.white,
        textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        side: BorderSide(color: onSurfaceColor, width: 2), // Double-defined border
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    ),

    // 4. Obvious Input Borders (Essential for accessibility)
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: onSurfaceColor, width: 2.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor, width: 3.0),
      ),
      labelStyle: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.bold),
    ),
  );
}
}
