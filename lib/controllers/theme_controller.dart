import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/theme_service.dart';

class ThemeController extends GetxController {
  final ThemeService _themeService = ThemeService();

  ThemeMode get themeMode => _themeService.getThemeMode();

  void switchTheme() {
    _themeService.switchTheme();
    Get.changeThemeMode(themeMode);
  }
}
