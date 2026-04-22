// // lib/services/ai_service.dart
// //
// // Hỗ trợ 2 provider: OpenAI (GPT-4o) và Google Gemini.
// // Chọn provider qua biến .env AI_PROVIDER=openai|gemini
// //
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// // ─── Exception ───────────────────────────────────────────────────────────────
//
// class AiException implements Exception {
//   final String message;
//   final int? statusCode;
//   AiException(this.message, {this.statusCode});
//
//   @override
//   String toString() => 'AiException($statusCode): $message';
// }
//
// // ─── AI Service interface ─────────────────────────────────────────────────────
//
// abstract class AiService {
//   /// Gửi danh sách lịch sử chat và nhận phản hồi từ AI.
//   /// [history] là list các map {role: 'user'|'assistant', content: String}
//   Future<String> sendMessage({
//     required String userMessage,
//     required List<Map<String, String>> history,
//   });
//
//   /// Phân tích ảnh chứa bài toán (OCR + solve)
//   Future<String> analyzeImage({required String base64Image});
//
//   factory AiService.fromEnv() {
//     final provider = dotenv.env['AI_PROVIDER'] ?? 'openai';
//     if (provider == 'gemini') return GeminiService();
//     return OpenAiService();
//   }
// }
//
// // ─── System prompt ────────────────────────────────────────────────────────────
//
// const _kSystemPrompt = '''
// Bạn là một gia sư toán đại số thông minh và thân thiện tên là "AlgebraBot".
//
// NHIỆM VỤ:
// - Giải các bài toán đại số từng bước rõ ràng, dễ hiểu
// - Giải thích từng bước bằng tiếng Việt
// - Dùng ký hiệu toán học đúng chuẩn
//
// ĐỊNH DẠNG TRẢ LỜI:
// - Bắt đầu bằng **Phân tích:** (nhận dạng dạng bài toán)
// - Tiếp theo các **Bước 1:**, **Bước 2:**... với giải thích chi tiết
// - Kết thúc bằng ✅ **Kết quả:** ghi rõ đáp án
// - Dùng markdown: **bold** cho tiêu đề bước
// - Dùng emoji phù hợp: 📌 cho bước, ✅ cho kết quả, ⚠️ cho lưu ý
//
// QUY TẮC:
// - Luôn trả lời bằng tiếng Việt trừ khi user hỏi bằng ngôn ngữ khác
// - Nếu bài toán không phải đại số, hướng dẫn user nhập đúng dạng
// - Không bịa kết quả — nếu không chắc, nói rõ
// - Nếu user hỏi không liên quan toán, lịch sự từ chối và hướng về toán học
// ''';
//
// // ─── OpenAI Implementation ────────────────────────────────────────────────────
//
// class OpenAiService implements AiService {
//   final String _apiKey;
//   final String _model;
//   final String _baseUrl = 'https://api.openai.com/v1/chat/completions';
//
//   OpenAiService()
//       : _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '',
//         _model = dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o';
//
//   @override
//   Future<String> sendMessage({
//     required String userMessage,
//     required List<Map<String, String>> history,
//   }) async {
//     if (_apiKey.isEmpty) throw AiException('OPENAI_API_KEY chưa được cấu hình');
//
//     final messages = [
//       {'role': 'system', 'content': _kSystemPrompt},
//       ...history,
//       {'role': 'user', 'content': userMessage},
//     ];
//
//     final response = await http
//         .post(
//           Uri.parse(_baseUrl),
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer $_apiKey',
//           },
//           body: jsonEncode({
//             'model': _model,
//             'messages': messages,
//             'max_tokens': 1500,
//             'temperature': 0.3, // thấp = nhất quán, chính xác hơn cho toán
//           }),
//         )
//         .timeout(const Duration(seconds: 30));
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(utf8.decode(response.bodyBytes));
//       return data['choices'][0]['message']['content'] as String;
//     } else if (response.statusCode == 401) {
//       throw AiException('API key không hợp lệ', statusCode: 401);
//     } else if (response.statusCode == 429) {
//       throw AiException('Đã vượt quá giới hạn request. Vui lòng thử lại sau.',
//           statusCode: 429);
//     } else {
//       final err = jsonDecode(response.body);
//       throw AiException(
//         err['error']?['message'] ?? 'Lỗi không xác định',
//         statusCode: response.statusCode,
//       );
//     }
//   }
//
//   @override
//   Future<String> analyzeImage({required String base64Image}) async {
//     if (_apiKey.isEmpty) throw AiException('OPENAI_API_KEY chưa được cấu hình');
//
//     // GPT-4o hỗ trợ vision trực tiếp
//     final response = await http
//         .post(
//           Uri.parse(_baseUrl),
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer $_apiKey',
//           },
//           body: jsonEncode({
//             'model': 'gpt-4o', // vision chỉ có gpt-4o
//             'messages': [
//               {'role': 'system', 'content': _kSystemPrompt},
//               {
//                 'role': 'user',
//                 'content': [
//                   {
//                     'type': 'image_url',
//                     'image_url': {
//                       'url': 'data:image/jpeg;base64,$base64Image',
//                       'detail': 'high',
//                     },
//                   },
//                   {
//                     'type': 'text',
//                     'text':
//                         'Hãy nhận diện bài toán đại số trong ảnh và giải từng bước chi tiết.',
//                   },
//                 ],
//               },
//             ],
//             'max_tokens': 2000,
//           }),
//         )
//         .timeout(const Duration(seconds: 45));
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(utf8.decode(response.bodyBytes));
//       return data['choices'][0]['message']['content'] as String;
//     } else {
//       throw AiException('Không thể phân tích ảnh',
//           statusCode: response.statusCode);
//     }
//   }
// }
//
// // ─── Gemini Implementation ────────────────────────────────────────────────────
//
// class GeminiService implements AiService {
//   final String _apiKey;
//   final String _model = 'gemini-1.5-flash';
//
//   GeminiService() : _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
//
//   String get _baseUrl =>
//       'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey';
//
//   @override
//   Future<String> sendMessage({
//     required String userMessage,
//     required List<Map<String, String>> history,
//   }) async {
//     if (_apiKey.isEmpty) throw AiException('GEMINI_API_KEY chưa được cấu hình');
//
//     // Gemini dùng 'user'/'model' thay vì 'user'/'assistant'
//     final contents = <Map<String, dynamic>>[];
//
//     // System prompt — ghép vào message đầu tiên của user
//     final firstUserContent =
//         '$_kSystemPrompt\n\n---\nNgười dùng: $userMessage';
//
//     if (history.isEmpty) {
//       contents.add({
//         'role': 'user',
//         'parts': [{'text': firstUserContent}],
//       });
//     } else {
//       // Đưa system vào đầu
//       contents.add({
//         'role': 'user',
//         'parts': [{'text': _kSystemPrompt}],
//       });
//       contents.add({
//         'role': 'model',
//         'parts': [{'text': 'Tôi hiểu. Tôi sẽ giải toán đại số theo đúng format.'}],
//       });
//       for (final h in history) {
//         contents.add({
//           'role': h['role'] == 'assistant' ? 'model' : 'user',
//           'parts': [{'text': h['content']}],
//         });
//       }
//       contents.add({
//         'role': 'user',
//         'parts': [{'text': userMessage}],
//       });
//     }
//
//     final response = await http
//         .post(
//           Uri.parse(_baseUrl),
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode({
//             'contents': contents,
//             'generationConfig': {
//               'temperature': 0.3,
//               'maxOutputTokens': 1500,
//             },
//           }),
//         )
//         .timeout(const Duration(seconds: 30));
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(utf8.decode(response.bodyBytes));
//       return data['candidates'][0]['content']['parts'][0]['text'] as String;
//     } else if (response.statusCode == 400) {
//       throw AiException('API key Gemini không hợp lệ', statusCode: 400);
//     } else {
//       throw AiException('Lỗi Gemini API', statusCode: response.statusCode);
//     }
//   }
//
//   @override
//   Future<String> analyzeImage({required String base64Image}) async {
//     if (_apiKey.isEmpty) throw AiException('GEMINI_API_KEY chưa được cấu hình');
//
//     final visionUrl =
//         'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey';
//
//     final response = await http
//         .post(
//           Uri.parse(visionUrl),
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode({
//             'contents': [
//               {
//                 'parts': [
//                   {
//                     'inline_data': {
//                       'mime_type': 'image/jpeg',
//                       'data': base64Image,
//                     },
//                   },
//                   {
//                     'text':
//                         '$_kSystemPrompt\n\nHãy nhận diện bài toán đại số trong ảnh và giải từng bước chi tiết.',
//                   },
//                 ],
//               },
//             ],
//             'generationConfig': {'temperature': 0.3, 'maxOutputTokens': 2000},
//           }),
//         )
//         .timeout(const Duration(seconds: 45));
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(utf8.decode(response.bodyBytes));
//       return data['candidates'][0]['content']['parts'][0]['text'] as String;
//     } else {
//       throw AiException('Không thể phân tích ảnh với Gemini',
//           statusCode: response.statusCode);
//     }
//   }
// }
