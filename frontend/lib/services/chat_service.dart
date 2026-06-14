import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';

class ChatApiService {
  static const String baseUrl = "${ApiConfig.baseUrl}/chat";

  // 1. Tạo cuộc hội thoại mới
  static Future<int> createConversation({
    required int problemId,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/conversation"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "problem_id": problemId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data["id"]; // Trả về conversation_id
    }
    throw Exception("Không thể tạo phiên trò chuyện");
  }

  // 2. Gửi tin nhắn hỏi AI
  static Future<String> sendMessage({
    required int conversationId,
    required String message,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/send"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "conversation_id": conversationId,
        "message": message,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["response"]; // Trả về text câu trả lời của AI
    }
    throw Exception("Gia sư AI đang bận, không thể gửi tin nhắn");
  }
}