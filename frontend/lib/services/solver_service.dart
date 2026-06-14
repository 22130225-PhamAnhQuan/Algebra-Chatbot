import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../core/constants/api_config.dart';
import '../models/solution_model.dart';

class SolverService {

  static Future<SolutionModel> solveText({
    required String problemText,
    required String token,
    int? gradeId,
    int? chapterId,
    int? lessonId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/solver/solve');

    final Map<String, dynamic> body = { "content": problemText, };

    if (gradeId != null) body["grade_id"] = gradeId;
    if (chapterId != null) body["chapter_id"] = chapterId;
    if (lessonId != null) body["lesson_id"] = lessonId;

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode != 200) {
      throw responseBody['detail'] ?? 'Server error';
    }

    if (responseBody['success'] != true) {
      throw responseBody.toString();
    }

    final solution = responseBody['solution'];

    if (solution is! Map<String, dynamic>) {
      throw "Invalid solution format";
    }

    print(
      const JsonEncoder.withIndent('  ')
          .convert(responseBody),
    );

    return SolutionModel.fromJson(solution);
  }

  static Future<SolutionModel> solveImage({
    required File imageFile,
    required String token,
    int? gradeId,
    int? chapterId,
    int? lessonId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/solver/solve-image');

    var request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    // Xác định định dạng ảnh dựa trên phần mở rộng file
    final extension = imageFile.path.split('.').last.toLowerCase();
    final mimeType = extension == 'png' ? 'png' : 'jpeg';

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType('image', mimeType),
      ),
    );

    if (gradeId != null) request.fields['grade_id'] = gradeId.toString();
    if (chapterId != null) request.fields['chapter_id'] = chapterId.toString();
    if (lessonId != null) request.fields['lesson_id'] = lessonId.toString();

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    final body = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode != 200) {
      final detail = body['detail'] ?? 'Lỗi tải ảnh lên';
      throw detail;
    }

    if (body['success'] != true) {
      throw body.toString();
    }

    final solution = body['solution'];

    if (solution is! Map<String, dynamic>) {
      throw "Invalid solution format";
    }

    return SolutionModel.fromJson(solution);
  }

  static Future<SolutionModel> solve({
    String? text,
    File? image,
    required String token,
    int? gradeId,
    int? chapterId,
    int? lessonId,
  }) async {
    if ((text == null || text.trim().isEmpty) && image == null) {
      throw Exception("Empty input");
    }

    return image != null
        ? solveImage(
            imageFile: image,
            token: token,
            gradeId: gradeId,
            chapterId: chapterId,
            lessonId: lessonId,
          )
        : solveText(
            problemText: text!,
            token: token,
            gradeId: gradeId,
            chapterId: chapterId,
            lessonId: lessonId,
          );
  }
}