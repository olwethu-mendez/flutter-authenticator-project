import 'package:authentipass/core/theme/theme_event.dart';
import 'package:authentipass/core/theme/theme_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences sharedPreferences;
  static const String themeKey = "APP_MODE";
  static const String highContrastKey = "HIGH_CONTRAST";// theme_bloc.dart (inside constructor)
static const String fontSizeKey = "FONT_SIZE_FACTOR";

// Initial state load:
// fontSizeFactor: sharedPreferences.getDouble(fontSizeKey) ?? 1.0,;

  ThemeBloc({required this.sharedPreferences})
    : super(
        ThemeState(
          appMode:
              AppMode.values[sharedPreferences.getInt(themeKey) ??
                  AppMode.system.index],
          isHighContrast: sharedPreferences.getBool(highContrastKey) ?? false,
        ),
      ) {
    on<ToggleThemeEvent>((event, emit) async {
      // Calculate the next index safely using modulo
      // (current index + 1) % total length cycles: 0 -> 1 -> 2 -> 0
      final nextIndex = (state.appMode.index + 1) % AppMode.values.length;
      final newMode = AppMode.values[nextIndex];

      // Persist the change
      await sharedPreferences.setInt(themeKey, newMode.index);
      emit(state.copyWith(appMode: newMode, isUpdatingMode: true));
    });

    on<SetThemeEvent>((event, emit) async {
      await sharedPreferences.setInt(themeKey, event.themeMode.index);
      // Use copyWith so you don't lose the High Contrast toggle state
      emit(state.copyWith(appMode: event.themeMode, isUpdatingMode: true));
    });

    on<ToggleHighContrastEvent>((event, emit) async {
      final newContrastValue = !state.isHighContrast;
      // Save to disk!
      await sharedPreferences.setBool(highContrastKey, newContrastValue);
      emit(state.copyWith(isHighContrast: newContrastValue, isUpdatingContrast: true));
    });

    on<ResetThemeFlagsEvent>((event, emit) {
      emit(state.copyWith(isUpdatingMode: false, isUpdatingContrast: false));
    });   

    on<ChangeFontSizeEvent>((event, emit) async {
      await sharedPreferences.setDouble(fontSizeKey, event.fontSizeFactor);
      emit(state.copyWith(fontSizeFactor: event.fontSizeFactor));
    });
  }
}
