import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';

class HistoryApiService {
  // 1. Lấy toàn bộ danh sách lịch sử chi tiết (Join 3 bảng)
  static Future<List<dynamic>> fetchHistory(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/history'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Decode UTF-8 để hiển thị đúng tiếng Việt các bước giải và đề bài
      final String responseBody = utf8.decode(response.bodyBytes);
      return jsonDecode(responseBody) as List<dynamic>;
    } else if (response.statusCode == 401) {
      throw 'Phiên đăng nhập hết hạn';
    } else {
      throw 'Lỗi server: ${response.statusCode}';
    }
  }

  // 2. Xóa một mục lịch sử
  static Future<bool> deleteHistoryItem(String token, int historyId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/history/$historyId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }
}