import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';

class ApiService {
  static Future<bool> register(
      String username,
      String email,
      String password,
      ) async {

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
      }),
    );

    print("STATUS CODE: ${response.statusCode}");
    print("RESPONSE BODY: ${response.body}");

    return response.statusCode == 200;

    return response.statusCode == 200;
  }
}