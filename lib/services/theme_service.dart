import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';

class ThemeService {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  /// Get isDarkMode info from local storage and return ThemeMode
  ThemeMode getThemeMode() {
    return _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;
  }

  /// Save isDarkMode to local storage
  bool _loadThemeFromBox() => _box.read(_key) ?? false;
  _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);

  /// Switch theme and save to local storage
  void switchTheme() {
    _saveThemeToBox(!_loadThemeFromBox());
  }
}
