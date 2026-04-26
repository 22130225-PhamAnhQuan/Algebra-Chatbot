import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_model.dart';
import '../models/solution_model.dart';
import '../services/solver_service.dart';
import '../services/ai_service.dart';

class ChatProvider extends ChangeNotifier {
  // Danh sách các tin nhắn hiển thị trên màn hình
  List<ChatMessage> messages = [];

  // Dữ liệu lời giải chi tiết (Dùng cho tin nhắn đầu tiên)
  SolutionModel? solutionData;

  bool isLoading = false; // Trạng thái khi giải bài đầu tiên
  bool isSending = false; // Trạng thái khi đang chat thêm với AI
  String errorMessage = "";
  int? currentConversationId;

  // --- HÀM 1: GIẢI BÀI TOÁN ĐẦU TIÊN (Fix lỗi solveProblem) ---
  Future<void> solveProblem(String problemText) async {
    if (problemText.trim().isEmpty) return; // Chặn gửi text rỗng [cite: 128]

    isLoading = true;
    errorMessage = "";
    solutionData = null;
    messages.clear();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? "";

      // 1. User Message
      messages.add(ChatMessage(
        sender: 'USER',
        content: problemText,
        type: 'text',
        createdAt: DateTime.now(),
      ));
      notifyListeners();

      // 2. Call API [cite: 70, 120]
      final result = await SolverService.solveProblem(
        problemText: problemText,
        token: token,
      );

      solutionData = result;

      // 3. Bot Message thành công [cite: 71, 73]
      messages.add(ChatMessage(
        sender: 'BOT',
        content: "Xong rồi! Đây là lời giải chi tiết cho bạn:",
        type: 'text',
        createdAt: DateTime.now(),
      ));

    } catch (e) {
      // Xử lý khi Backend trả về lỗi 500 hoặc mất kết nối AI [cite: 124]
      errorMessage = e.toString();
      messages.add(ChatMessage(
        sender: 'BOT',
        content: "⚠️ Lỗi: $errorMessage. Bạn hãy kiểm tra lại kết nối AI (Ollama) nhé!",
        type: 'text',
        createdAt: DateTime.now(),
      ));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // --- HÀM 2: GỬI TIN NHẮN CHAT TIẾP THEO ---
  Future<void> sendUserMessage(String content) async {
    if (content.trim().isEmpty) return;

    final userMsg = ChatMessage(
      sender: 'USER',
      content: content,
      type: 'text',
      createdAt: DateTime.now(),
    );

    messages.add(userMsg);
    isSending = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? "";

      // Gọi API Chat (Phần này kết nối với Backend Phi-3)
      final botMsg = await ChatApiService.sendMessage(
        conversationId: currentConversationId ?? 0,
        content: content,
        token: token,
      );

      messages.add(botMsg);
    } catch (e) {
      debugPrint("Lỗi gửi tin nhắn: $e");
    } finally {
      isSending = false;
      notifyListeners();
    }
  }
}