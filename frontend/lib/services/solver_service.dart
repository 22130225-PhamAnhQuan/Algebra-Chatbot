import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';
import '../models/solution_model.dart';

class SolverService {

  static Future<SolutionModel> solveProblem({
    required String problemText,
    required String token,
  }) async {

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/solver/solver'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'text': problemText}),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonData = jsonDecode(responseBody);
      return SolutionModel.fromJson(jsonData);

    } else if (response.statusCode == 401) {
      throw 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';

    } else {
      try {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw errorData['detail'] ?? 'Lỗi hệ thống: ${response.statusCode}';
      } catch (_) {
        throw 'Không thể kết nối đến máy chủ. Mã lỗi: ${response.statusCode}';
      }
    }
  }
}