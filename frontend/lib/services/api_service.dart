import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Dùng cho debugPrint
import 'package:shared_preferences/shared_preferences.dart'; // Thêm thư viện này
import '../core/constants/api_config.dart';
import '../models/user_model.dart'; // Thêm import model (nhớ kiểm tra đúng đường dẫn của bạn)

class ApiService {

  static Future<String> register({
    required String name,
    required String email,
    required String password
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password
      }),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      return data['access_token']; // Trả về thẻ bài
    } else {
      throw data['detail'] ?? 'Đăng ký thất bại';
    }
  }

  static Future<String> login({required String email, required String password}) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      final token = data['access_token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      return token;
    } else {
      throw data["detail"] ?? 'Sai email hoặc mật khẩu';
    }
  }

  static Future<String> loginWithGoogle(String idToken) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/google"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'id_token': idToken}),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      return data['access_token'];
    } else {
      throw data['detail'] ?? 'Lỗi xác thực Google';
    }
  }

  static Future<void> forgotPassword(String email) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/forgot-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)["detail"]);
    }
  }

  static Future<void> verifyOtp({required String email, required String otp}) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'email': email,
        'otp': otp
      }),
    );

    if (response.statusCode != 200) {
      try {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        throw error['detail'] ?? 'Mã OTP không hợp lệ';
      } catch (e) {
        if (e.toString().contains('FormatException')) {
          throw 'Hệ thống máy chủ đang gặp sự cố (Lỗi 500).';
        }
        rethrow;
      }
    }
  }

  static Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/reset-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otp": otp,
        "new_password": newPassword,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)["detail"]);
    }
  }

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

  // Lấy thông tin cá nhân
  static Future<UserModel> getUserProfile() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/users/profile'),
      headers: await _getHeaders(),
    );
    print("Dữ liệu Backend trả về: ${response.body}");
    if (response.statusCode == 200) {
      // Giải mã byte sang chuỗi UTF-8 trước khi decode JSON
      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> userData = jsonDecode(responseBody);
      return UserModel.fromJson(userData);
    }
    throw 'Không thể tải thông tin người dùng. Vui lòng đăng nhập lại.';
  }

  // Cập nhật Tên, Email
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

  // Đổi mật khẩu
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

  // Báo Backend thu hồi Token
  static Future<void> logout() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/logout'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        debugPrint("Backend đã thu hồi phiên đăng nhập thành công.");
      }
    } catch (e) {
      debugPrint("Lỗi gọi API logout: $e");
    }
  }
}