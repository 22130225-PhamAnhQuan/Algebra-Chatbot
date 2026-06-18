import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_model.dart';
import '../models/solution_model.dart';
import '../services/solver_service.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatMessage> messages = [];
  SolutionModel? solutionData;
  bool isLoading = false;
  bool isSending = false;
  String errorMessage = "";
  int? currentConversationId;

  Future<void> setInitialSolution(String problemText, SolutionModel solution) async {
    messages.clear();
    solutionData = solution;
    currentConversationId = solution.conversationId;

    // 1. LUÔN LUÔN hiển thị đề bài và lời giải toán ở đầu màn hình
    messages.add(ChatMessage(
      sender: 'USER',
      content: problemText,
      type: 'text',
      createdAt: DateTime.now(),
    ));
    messages.add(ChatMessage(
      sender: 'BOT',
      content: "Xong rồi! Đây là lời giải chi tiết cho bạn:",
      type: 'text',
      createdAt: DateTime.now(),
    ));

    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (currentConversationId != null && token != null) {
        final historyMessages = await ChatApiService.getChatHistory(
          conversationId: currentConversationId!,
          token: token,
        );

        if (historyMessages.isNotEmpty) {
          messages.addAll(historyMessages);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Lỗi tải lịch sử chat: $e");
    }
  }

  Future<void> solveProblem(String problemText) async {
    if (problemText.trim().isEmpty) return;

    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw "Chưa đăng nhập";

      messages.add(ChatMessage(
        sender: 'USER',
        content: problemText,
        type: 'text',
        createdAt: DateTime.now(),
      ));
      notifyListeners();

      // 1. GỌI API GIẢI TOÁN
      final result = await SolverService.solve(
        text: problemText,
        token: token,
      );
      solutionData = result;

      if (result.problemId != null) {
        final conversationId = await ChatApiService.createConversation(
          problemId: result.problemId!,
          token: token,
        );
        currentConversationId = conversationId;
        debugPrint("[ChatProvider] Đã tạo thành công Conversation ID: $currentConversationId");
      }

      if (result.conversationId != null) {
        currentConversationId = result.conversationId;
        debugPrint("[ChatProvider] Đã nhận Conversation ID từ Backend: $currentConversationId");
      } else {
        debugPrint("[ChatProvider] Không có conversationId!");
      }

      messages.add(ChatMessage(
        sender: 'BOT',
        content: "Xong rồi! Đây là lời giải chi tiết cho bạn:",
        type: 'text',
        createdAt: DateTime.now(),
      ));

    } catch (e) {
      debugPrint("[ChatProvider] Lỗi giải toán: $e");
      messages.add(ChatMessage(
        sender: 'BOT',
        content: "Lỗi hệ thống: $e",
        type: 'text',
        createdAt: DateTime.now(),
      ));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendUserMessage(String content) async {
    if (content.trim().isEmpty) return;

    // 1. Thêm tin nhắn của User
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
      if (token == null) throw "Chưa đăng nhập";

      if (currentConversationId == null) {
        throw "Chưa có ID cuộc trò chuyện. Hãy chắc chắn bạn đã tạo Conversation.";
      }

      // 2. Gọi API gửi tin nhắn
      final aiReplyText = await ChatApiService.sendMessage(
        conversationId: currentConversationId!,
        message: content,
        token: token,
      );

      // 3. Thêm câu trả lời của AI vào giao diện
      messages.add(ChatMessage(
        sender: 'BOT',
        content: aiReplyText,
        type: 'text', // Dùng type text vì ChatScreen đã tự động bọc Math.tex rồi
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
      isSending = false;
      notifyListeners();
    }
  }
}