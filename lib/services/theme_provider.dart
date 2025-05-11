import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  // تحميل الثيم من SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('themeMode');

    if (themeModeIndex != null && themeModeIndex >= 0 && themeModeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeModeIndex];
      debugPrint('🔄 تم تحميل الثيم: $_themeMode');
    } else {
      _themeMode = ThemeMode.light;
      debugPrint('⚠️ لم يتم العثور على ثيم محفوظ. تعيين الوضع الفاتح كافتراضي.');
    }

    notifyListeners();
  }

  // تغيير الثيم وحفظه
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) {
      debugPrint('ℹ️ نفس الثيم مختار مسبقًا: $mode');
      return;
    }

    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);

    debugPrint('✅ تم تغيير الثيم إلى: $_themeMode');
    notifyListeners();
  }

  // التبديل بين الوضع الفاتح والداكن
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }
}
