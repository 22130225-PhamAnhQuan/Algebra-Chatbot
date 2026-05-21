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
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/solve');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "content": problemText,
      }),
    );

    final body = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode != 200) {
      throw body['detail'] ?? 'Server error';
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

  static Future<SolutionModel> solveImage({
    required File imageFile,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/solve-image');

    var request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    final body = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode != 200) {
      throw body['detail'] ?? 'Server error';
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
  }) async {
    if ((text == null || text.trim().isEmpty) && image == null) {
      throw Exception("Empty input");
    }

    return image != null
        ? solveImage(imageFile: image, token: token)
        : solveText(problemText: text!, token: token);
  }
}