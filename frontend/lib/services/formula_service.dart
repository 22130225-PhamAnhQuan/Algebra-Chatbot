import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';
import '../models/formula_model.dart';

class FormulaService {
  // 1. Lấy danh sách công thức theo khối lớp (6, 7, 8, 9)
  static Future<List<Formula>> getByGrade(int grade) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/formulas/grade/$grade"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json; charset=utf-8",
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // QUAN LƯU Ý: Phải dùng utf8.decode để xử lý ký tự toán học (², ³, √)
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);

        return data.map((json) => Formula.fromJson(json)).toList();
      } else {
        throw Exception("Lỗi server: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi tại FormulaService.getByGrade: $e");
      throw Exception("Không thể kết nối đến máy chủ.");
    }
  }

  // 2. Tìm kiếm công thức (Dùng cho tính năng Search sau này)
  static Future<List<Formula>> searchFormulas(String keyword) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/formulas/search?keyword=$keyword"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => Formula.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Lỗi tìm kiếm: $e");
      return [];
    }
  }

  // 3. Lấy toàn bộ công thức (Nếu cần dùng cho trang tổng hợp)
  static Future<List<Formula>> getAllFormulas() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/formulas/all"),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => Formula.fromJson(json)).toList();
    }
    return [];
  }

  static Future<Formula> getById(int id) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/formulas/$id"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json; charset=utf-8",
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Vẫn phải dùng utf8.decode để không lỗi ký tự toán học
        final String decodedBody = utf8.decode(response.bodyBytes);
        return Formula.fromJson(json.decode(decodedBody));
      } else {
        throw Exception("Không tìm thấy công thức (Mã lỗi: ${response.statusCode})");
      }
    } catch (e) {
      print("Lỗi tại FormulaService.getById: $e");
      throw Exception("Lỗi khi kết nối lấy chi tiết công thức.");
    }
  }
}