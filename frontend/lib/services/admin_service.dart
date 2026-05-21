import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';

class AdminService {

  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ==========================================
  // 1. THỐNG KÊ HỆ THỐNG (DASHBOARD STATISTICS)
  // ==========================================
  Future<Map<String, dynamic>?> getDashboardStats(String token) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/admin/dashboard-stats"),
        headers: _getHeaders(token),
      );
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return null;
    } catch (e) {
      print("Lỗi getDashboardStats: $e");
      return null;
    }
  }

  // ==========================================
  // 2. QUẢN LÝ TÀI KHOẢN (USER MANAGEMENT)
  // ==========================================
  Future<List<dynamic>?> getAllUsers(String token) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/admin/users"),
        headers: _getHeaders(token),
      );
      if (response.statusCode == 200) {
        final resBody = jsonDecode(response.body);

        return resBody['data'] as List<dynamic>;
      }
      return null;
    } catch (e) {
      print("Lỗi getAllUsers: $e");
      return null;
    }
  }

  Future<bool> toggleUserStatus(String token, int userId) async {
    try {
      final response = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/admin/users/$userId/toggle-status"),
        headers: _getHeaders(token),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi toggleUserStatus: $e");
      return false;
    }
  }

  // ==========================================
  // 3. QUẢN LÝ LOG HỆ THỐNG AI (AI LOGS MANAGEMENT)
  // ==========================================
  Future<List<dynamic>?> getAILogs(String token, {int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/admin/ai-logs?limit=$limit"),
        headers: _getHeaders(token),
      );
      if (response.statusCode == 200) {
        final result = jsonDecode(utf8.decode(response.bodyBytes));
        return result['data'];
      }
      return null;
    } catch (e) {
      print("Lỗi getAILogs: $e");
      return null;
    }
  }

  // ==========================================
  // 4. QUẢN LÝ LỊCH SỬ BÀI GIẢI (HISTORY MANAGEMENT)
  // ==========================================
  Future<List<dynamic>?> getAllHistories(String token, {int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/admin/histories?limit=$limit"),
        headers: _getHeaders(token),
      );
      if (response.statusCode == 200) {
        final result = jsonDecode(utf8.decode(response.bodyBytes));
        return result['data'];
      }
      return null;
    } catch (e) {
      print("Lỗi getAllHistories: $e");
      return null;
    }
  }

  // ==========================================
  // 5. QUẢN LÝ GIÁO TRÌNH / CÔNG THỨC TOÁN (FORMULAS MANAGEMENT)
  // ==========================================

  // [READ] Lấy danh sách công thức, hỗ trợ lọc theo khối lớp (Toán 6 -> Toán 9)
  Future<List<dynamic>?> getAllFormulas(String token, {int? grade}) async {
    try {
      String url = "${ApiConfig.baseUrl}/admin/formulas";
      if (grade != null) {
        url += "?grade=$grade";
      }
      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(token),
      );
      if (response.statusCode == 200) {
        final result = jsonDecode(utf8.decode(response.bodyBytes));
        return result['data'];
      }
      return null;
    } catch (e) {
      print("Lỗi getAllFormulas: $e");
      return null;
    }
  }

  // [READ CHI TIẾT] Lấy thông tin chi tiết đầy đủ của 1 công thức
  Future<Map<String, dynamic>?> getFormulaDetail(String token, int formulaId) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/admin/formulas/$formulaId"),
        headers: _getHeaders(token),
      );
      if (response.statusCode == 200) {
        final result = jsonDecode(utf8.decode(response.bodyBytes));
        return result['data'];
      }
      return null;
    } catch (e) {
      print("Lỗi getFormulaDetail: $e");
      return null;
    }
  }

  // [CREATE] Thêm mới công thức bao gồm đầy đủ các trường (explanation, example, category...)
  Future<bool> createFormula(String token, Map<String, dynamic> formulaData) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/admin/formulas"),
        headers: _getHeaders(token),
        body: jsonEncode(formulaData),
      );
      return response.statusCode == 201; // Trả về 201 Created theo đúng Backend
    } catch (e) {
      print("Lỗi createFormula: $e");
      return false;
    }
  }

  // [UPDATE] Chỉnh sửa công thức toán học
  Future<bool> updateFormula(String token, int formulaId, Map<String, dynamic> formulaData) async {
    try {
      final response = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/admin/formulas/$formulaId"),
        headers: _getHeaders(token),
        body: jsonEncode(formulaData),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi updateFormula: $e");
      return false;
    }
  }

  // [DELETE] Xóa công thức khỏi kho dữ liệu giáo trình
  Future<bool> deleteFormula(String token, int formulaId) async {
    try {
      final response = await http.delete(
        Uri.parse("${ApiConfig.baseUrl}/admin/formulas/$formulaId"),
        headers: _getHeaders(token),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi deleteFormula: $e");
      return false;
    }
  }
}