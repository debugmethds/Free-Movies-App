import 'package:flutter/material.dart';
import '../datasource/preferences.dart';

class PreferencesRepository {
  final Preferences preferences;

  PreferencesRepository({required this.preferences});

  Future<void> setThemeMode(ThemeMode mode) async {
    await preferences.setThemeMode(mode.index);
  }

  Future<ThemeMode> getThemeMode() async {
    final rawValue = await preferences.getThemeMode();

    if (rawValue == ThemeMode.light.index) {
      return ThemeMode.light;
    } else {
      return ThemeMode.dark;
    }
  }
}
