import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  // Thay đổi trạng thái sáng/tối
  void toggleTheme(bool isOn) async {
    _isDarkMode = isOn;
    notifyListeners(); // Thông báo cho toàn bộ App vẽ lại giao diện

    // Lưu lại lựa chọn vào bộ nhớ máy
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isOn);
  }

  // Load lại cấu hình cũ khi vừa mở App
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  // Lấy ThemeMode tương ứng
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
}