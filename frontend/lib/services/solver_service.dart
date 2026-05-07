import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../core/constants/api_config.dart';
import '../models/solution_model.dart';

class SolverService {
  static Future<SolutionModel> solveProblem({
    String? problemText,
    File? imageFile,
    required String token,
  }) async {
    try {
      // Endpoint đúng theo router của bạn: /solver/solver
      final uri = Uri.parse('${ApiConfig.baseUrl}/solver/solver');
      var request = http.MultipartRequest('POST', uri);

      // 1. Thêm Header
      request.headers['Authorization'] = 'Bearer $token';

      // 2. Thêm trường Text (Form) nếu có
      if (problemText != null) {
        request.fields['text'] = problemText;
      }

      // 3. Thêm trường Image (File) nếu có
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image', // Key phải khớp với tham số 'image' trong router FastAPI
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      // 4. Gửi và nhận phản hồi
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));

        // Backend trả về {"status": "success", "data": {...}}
        if (body['status'] == 'success') {
          return SolutionModel.fromJson(body['data']);
        } else {
          throw 'Xử lý thất bại';
        }
      } else if (response.statusCode == 401) {
        throw 'Phiên đăng nhập hết hạn';
      } else {
        throw 'Lỗi hệ thống: ${response.statusCode}';
      }
    } catch (e) {
      rethrow;
    }
  }
}