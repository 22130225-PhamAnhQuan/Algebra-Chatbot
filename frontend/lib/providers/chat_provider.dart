import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_model.dart';
import '../models/solution_model.dart';
import '../services/solver_service.dart';
import '../services/ai_service.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatMessage> messages = [];
  SolutionModel? solutionData;
  bool isLoading = false;
  bool isSending = false;
  String errorMessage = "";

  // --- HÀM MỚI: Nhận kết quả có sẵn từ màn hình trước ---
  void setInitialSolution(String problemText, SolutionModel solution) {
    messages.clear();
    solutionData = solution;

    // Thêm câu hỏi của User
    messages.add(ChatMessage(
      sender: 'USER',
      content: problemText,
      type: 'text',
      createdAt: DateTime.now(),
    ));

    // Thêm phản hồi của Bot
    messages.add(ChatMessage(
      sender: 'BOT',
      content: "Xong rồi! Đây là lời giải chi tiết cho bạn:",
      type: 'text',
      createdAt: DateTime.now(),
    ));

    notifyListeners();
  }

  // --- GIẢI BÀI (Dùng khi không có dữ liệu sẵn) ---
  Future<void> solveProblem(String problemText) async {
    if (problemText.trim().isEmpty) return;

    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw "Chưa đăng nhập";
      }

      messages.add(ChatMessage(
        sender: 'USER',
        content: problemText,
        type: 'text',
        createdAt: DateTime.now(),
      ));

      notifyListeners();

      final result = await SolverService.solve(
        text: problemText,
        token: token,
      );

      solutionData = result;

      messages.add(ChatMessage(
        sender: 'BOT',
        content: "Xong rồi! Đây là lời giải chi tiết cho bạn:",
        type: 'text',
        createdAt: DateTime.now(),
      ));

    } catch (e) {
      messages.add(ChatMessage(
        sender: 'BOT',
        content: "Lỗi: $e",
        type: 'text',
        createdAt: DateTime.now(),
      ));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // --- CHAT TIẾP THEO ---
  Future<void> sendUserMessage(String content) async {
    if (content.trim().isEmpty) return;

    final message = ChatMessage(
      sender: 'USER',
      content: content,
      type: 'text',
      createdAt: DateTime.now(),
    );

    messages.add(message);
    isSending = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw "Chưa đăng nhập";
      }

      final botMsg = await ChatApiService.sendMessage(
        conversationId: 0,
        content: content,
        token: token,
      );

      messages.add(botMsg);

    } catch (e) {
      messages.add(ChatMessage(
        sender: 'BOT',
        content: "Lỗi: $e",
        type: 'text',
        createdAt: DateTime.now(),
      ));
    } finally {
      isSending = false;
      notifyListeners();
    }
  }
}