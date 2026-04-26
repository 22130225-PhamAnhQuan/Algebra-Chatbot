import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_config.dart';
import '../models/user_model.dart';

class UserService {

  // Tự động lấy Token từ bộ nhớ đính kèm vào Header
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    debugPrint("GỬI TOKEN: Bearer $token");
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // LẤY PROFILE
  static Future<UserModel> getUserProfile() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/users/profile'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> userData = jsonDecode(responseBody);
      return UserModel.fromJson(userData);
    } else if (response.statusCode == 401) {
      throw 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    } else {
      throw 'Không thể tải thông tin người dùng. Mã lỗi: ${response.statusCode}';
    }
  }

  // CẬP NHẬT PROFILE
  static Future<void> updateProfile({required String name, required String email}) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/users/update'),
      headers: await _getHeaders(),
      body: jsonEncode({'name': name, 'email': email}),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      throw data['detail'] ?? 'Lỗi cập nhật hồ sơ';
    }
  }

  // ĐỔI MẬT KHẨU
  static Future<void> changePassword({required String oldPassword, required String newPassword}) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/users/change-password'),
      headers: await _getHeaders(),
      body: jsonEncode({'old_password': oldPassword, 'new_password': newPassword}),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      throw data['detail'] ?? 'Lỗi đổi mật khẩu';
    }
  }

  // LOGOUT
  static Future<void> logout() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/users/logout'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        debugPrint("Backend đã thu hồi phiên đăng nhập thành công.");
      }
    } catch (e) {
      debugPrint("Lỗi gọi API logout: $e");
    } finally {
      // Dù API có lỗi hay không, bắt buộc phải xóa token ở Local
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    }
  }
}