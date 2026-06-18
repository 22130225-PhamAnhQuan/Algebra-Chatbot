import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';
import '../models/chat_model.dart';

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

  static Future<List<ChatMessage>> getChatHistory({
    required int conversationId,
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse("$baseUrl/chat/messages/$conversationId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((msg) => ChatMessage(
        // Chuyển đổi 'role' từ DB thành 'sender' cho UI
        sender: msg['role'] == 'user' ? 'USER' : 'BOT',
        content: msg['content'],
        type: 'text',
        createdAt: DateTime.parse(msg['created_at'] ?? DateTime.now().toIso8601String()),
      )).toList();
    }
    throw Exception("Không thể tải lịch sử trò chuyện");
  }
}