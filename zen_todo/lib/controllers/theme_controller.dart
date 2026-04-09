import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:zen_todo/services/haptic_service.dart';

enum AppTheme { acrylic, oled, light }

final themeControllerProvider = StateNotifierProvider<ThemeController, AppTheme>((ref) {
  return ThemeController(Hive.box<String>('settings'));
});

class ThemeController extends StateNotifier<AppTheme> {
  ThemeController(this._settingsBox) : super(AppTheme.acrylic) {
    _load();
  }

  final Box<String> _settingsBox;
  static const String _themeKey = 'app_theme';

  void _load() {
    final String? value = _settingsBox.get(_themeKey);
    if (value != null) {
      state = AppTheme.values.firstWhere(
        (e) => e.name == value,
        orElse: () => AppTheme.acrylic,
      );
    }
  }

  Future<void> setTheme(AppTheme theme) async {
    state = theme;
    HapticService.onThemeChange();
    await _settingsBox.put(_themeKey, theme.name);
  }
}

ThemeData themeDataFor(AppTheme theme) {
  switch (theme) {
    case AppTheme.acrylic:
      return ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF10131A),
        cardColor: Colors.white.withOpacity(0.08),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9CA3FF),
          brightness: Brightness.dark,
        ),
      );
    case AppTheme.oled:
      return ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        cardColor: const Color(0xFF101010),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.dark,
          surface: Colors.black,
        ),
      );
    case AppTheme.light:
      return ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        cardColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5F6FFF)),
      );
  }
}
