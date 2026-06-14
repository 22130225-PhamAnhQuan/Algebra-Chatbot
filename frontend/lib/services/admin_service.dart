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

  Future<List<dynamic>?> getGrades(
      String token,
      ) async {
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/admin/grades",
        ),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        return result["data"];
      }

      return [];
    } catch (e) {
      print("Lỗi getGrades: $e");
      return [];
    }
  }

  Future<List<dynamic>?> getChapters(
      String token,
      int gradeId,
      ) async {
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/admin/grades/$gradeId/chapters",
        ),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        return result["data"];
      }

      return [];
    } catch (e) {
      print("Lỗi getChapters: $e");
      return [];
    }
  }
  Future<List<dynamic>?> getLessons(
      String token,
      int chapterId,
      ) async {
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/admin/chapters/$chapterId/lessons",
        ),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        return result["data"];
      }

      return [];
    } catch (e) {
      print("Lỗi getLessons: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getLessonDetail(
      String token,
      int lessonId,
      ) async {
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/admin/lessons/$lessonId",
        ),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(
          utf8.decode(response.bodyBytes),
        );
      }

      return null;
    } catch (e) {
      print("Lỗi getLessonDetail: $e");
      return null;
    }
  }
  Future<bool> createLesson(
      String token,
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await http.post(
        Uri.parse(
          "${ApiConfig.baseUrl}/admin/curriculum/lessons",
        ),
        headers: _getHeaders(token),
        body: jsonEncode(data),
      );

      return response.statusCode == 201;
    } catch (e) {
      print("Lỗi createLesson: $e");
      return false;
    }
  }

  Future<bool> updateLesson(
      String token,
      int lessonId,
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await http.put(
        Uri.parse(
          "${ApiConfig.baseUrl}/admin/lessons/$lessonId",
        ),
        headers: _getHeaders(token),
        body: jsonEncode(data),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi updateLesson: $e");
      return false;
    }
  }

  Future<bool> deleteLesson(
      String token,
      int lessonId,
      ) async {
    try {
      final response = await http.delete(
        Uri.parse(
          "${ApiConfig.baseUrl}/admin/lessons/$lessonId",
        ),
        headers: _getHeaders(token),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi deleteLesson: $e");
      return false;
    }
  }
}