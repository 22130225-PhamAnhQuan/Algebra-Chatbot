import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String _error = '';

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String get error => _error;

  // 1. Tải thông tin User
  Future<void> loadUser() async {
    try {
      _isLoading = true;

      // Gọi API lấy profile
      final userData = await UserService.getUserProfile();

      if (userData != null) {
        _user = userData;
        _error = '';
      }
    } catch (e) {
      _error = e.toString();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners(); // Đây là lúc UI nhận được tín hiệu để vẽ lại "quan"
    }
  }

  // 2. Cập nhật hồ sơ (Hàm mà dòng 191 báo thiếu)
  Future<bool> updateProfile({required String name, required String email}) async {
    try {
      _isLoading = true;

      await UserService.updateProfile(name: name, email: email);
      await loadUser(); // Tải lại thông tin mới
      print("AuthProvider đã nhận user: ${_user?.name}");
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Đổi mật khẩu
  Future<bool> changePassword({required String oldPassword, required String newPassword}) async {
    try {
      _isLoading = true;
      notifyListeners();

      await UserService.changePassword(oldPassword: oldPassword, newPassword: newPassword);
      return true;
    } catch (e) {
      _error = e.toString();
      print("Lỗi tại AuthProvider: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 4. Đăng xuất
  Future<void> logout() async {
    try {
      await UserService.logout(); // Gọi backend xóa Refresh Token (nếu có)
    } catch (e) {
      debugPrint("Lỗi logout backend: $e");
    }

    // Xóa token ở máy
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    _user = null;
    notifyListeners();
  }
}