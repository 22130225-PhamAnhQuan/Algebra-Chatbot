import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/solution_model.dart';

class SolveService {

  Future<SolutionModel> solveMathProblem(String text) async {
    Uri.parse("${ApiConfig.baseUrl}/auth/register"),
    headers: {"Content-Type": "application/json"},
    request.fields['text'] = text;

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonData = json.decode(utf8.decode(response.bodyBytes));
        return SolutionModel.fromJson(jsonData);
      } else {
        throw Exception("Lỗi Server: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Không thể kết nối tới Server. Vui lòng thử lại!");
    }
  }
}