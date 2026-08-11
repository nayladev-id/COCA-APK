// lib/utils/theme_manager.dart
// Mengelola state tema (Light/Dark) di seluruh aplikasi secara reaktif.

import 'package:flutter/material.dart';

class ThemeManager {
  // ValueNotifier untuk memantau perubahan tema
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);

  static void toggleTheme() {
    if (themeNotifier.value == ThemeMode.light) {
      themeNotifier.value = ThemeMode.dark;
    } else {
      themeNotifier.value = ThemeMode.light;
    }
  }
}
