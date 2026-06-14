import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_config.dart';

class AuthService {

  // Tự động lấy Token từ bộ nhớ (dùng cho logout)
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ĐĂNG KÝ
  static Future<String> register({
    required String name,
    required String email,
    required String password
  }) async {
    try {
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        return data['access_token'];
      } else {
        throw data['detail'] ?? 'Đăng ký thất bại';
      }
    } catch (e) {
      if (e is FormatException) throw 'Máy chủ gặp sự cố.';
      rethrow;
    }
  }

  // ĐĂNG NHẬP
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
      // Lưu thẻ bài vào bộ nhớ
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return token;
    } else {
      throw data["detail"] ?? 'Sai email hoặc mật khẩu';
    }
  }

  // ĐĂNG NHẬP GOOGLE
  static Future<String> loginWithGoogle(String idToken) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/google"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'id_token': idToken}),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      final token = data['access_token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return token;
    } else {
      throw data['detail'] ?? 'Lỗi xác thực Google';
    }
  }

  // QUÊN MẬT KHẨU
  static Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/forgot-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    if (response.statusCode != 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(data["detail"] ?? "Lỗi gửi yêu cầu khôi phục");
    }
  }

  // XÁC THỰC OTP
  static Future<void> verifyOtp({required String email, required String otp}) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    if (response.statusCode != 200) {
      try {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        throw error['detail'] ?? 'Mã OTP không hợp lệ';
      } catch (e) {
        if (e is FormatException) throw 'Hệ thống máy chủ đang gặp sự cố (Lỗi 500).';
        rethrow;
      }
    }
  }

  // ĐẶT LẠI MẬT KHẨU
  static Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/reset-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otp": otp,
        "new_password": newPassword,
      }),
    );
    if (response.statusCode != 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(data["detail"] ?? "Lỗi đặt lại mật khẩu");
    }
  }

}