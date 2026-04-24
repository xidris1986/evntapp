import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef ThemeModeCallback = void Function(ThemeMode mode);

class SettingsService {
  static const String _themeKey = 'theme_mode';
  
  SharedPreferences? _prefs;
  final List<ThemeModeCallback> _listeners = [];
  ThemeMode? _currentMode;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<ThemeMode> getThemeMode() async {
    try {
      if (_currentMode != null) return _currentMode!;

      if (_prefs == null) await init();

      final value = _prefs!.getString(_themeKey);
      _currentMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == value,
        orElse: () => ThemeMode.system,
      );
      return _currentMode!;
    } catch (e) {
      debugPrint('Error getting theme mode: $e');
      return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      if (_prefs == null) await init();

      await _prefs!.setString(_themeKey, mode.toString());
      _currentMode = mode;
      for (final listener in _listeners) {
        listener(mode);
      }
    } catch (e) {
      debugPrint('Error setting theme mode: $e');
      _currentMode = ThemeMode.system;
    }
  }

  void addListener(ThemeModeCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(ThemeModeCallback listener) {
    _listeners.remove(listener);
  }
}