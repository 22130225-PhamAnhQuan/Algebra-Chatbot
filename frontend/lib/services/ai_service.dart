// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../core/constants/api_config.dart';
// import '../models/chat_model.dart';
//
// class ChatApiService {
//   // Gửi tin nhắn mới và nhận phản hồi từ AI
//   static Future<ChatMessage> sendMessage({
//     required int conversationId,
//     required String content,
//     required String token, required String message,
//   }) async {
//     final response = await http.post(
//       Uri.parse("${ApiConfig.baseUrl}/api/chat/send"),
//       headers: {
//         "Content-Type": "application/json",
//         "Authorization": "Bearer $token",
//       },
//       body: jsonEncode({
//         "conversation_id": conversationId,
//         "content": content,
//         "type": "text",
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       return ChatMessage.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
//     } else {
//       throw Exception("Lỗi khi gửi tin nhắn");
//     }
//   }
// }