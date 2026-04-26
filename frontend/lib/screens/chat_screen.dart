import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../core/theme/app_theme.dart';
import '../providers/chat_provider.dart';
import '../models/chat_model.dart';

class ChatScreen extends StatefulWidget {
  final String problem;
  const ChatScreen({super.key, required this.problem});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Khởi tạo giải bài toán ngay khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).solveProblem(widget.problem);
    });
  }

  // Tự động cuộn xuống khi có tin nhắn mới
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                // Cuộn xuống khi danh sách thay đổi
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.messages.length + (provider.isSending ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Hiển thị trạng thái AI đang gõ
                    if (index == provider.messages.length) {
                      return _buildLoadingState();
                    }

                    final msg = provider.messages[index];
                    if (msg.sender == 'USER') {
                      return _buildUserBubble(msg.content);
                    } else {
                      // Tin nhắn đầu tiên của Bot (index 1) thường là lời giải chi tiết
                      // Bạn có thể tùy biến logic này dựa trên flow của mình
                      bool isSolution = (index == 1 && provider.solutionData != null);
                      return _buildBotBubble(msg.content, isSolution: isSolution);
                    }
                  },
                );
              },
            ),
          ),
          _buildChatInput(),
        ],
      ),
    );
  }

  // ================= BONG BÓNG NGƯỜI DÙNG =================
  Widget _buildUserBubble(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E9FF),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: Text(
            text,
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  // ================= BONG BÓNG AI =================
  Widget _buildBotBubble(String content, {bool isSolution = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 16,
            child: Icon(Icons.auto_awesome, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: isSolution ? _buildSolutionContent() : _buildSimpleText(content),
            ),
          ),
        ],
      ),
    );
  }

  // Nội dung chat bình thường (hỗ trợ LaTeX)
  Widget _buildSimpleText(String text) {
    return Math.tex(
      text,
      textStyle: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
      onErrorFallback: (err) => Text(text),
    );
  }

  // Nội dung lời giải chi tiết (Dùng Model Solution của bạn)
  Widget _buildSolutionContent() {
    final provider = Provider.of<ChatProvider>(context, listen: false);
    final data = provider.solutionData;
    if (data == null) return const Text("Đang tải lời giải...");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text("Xong rồi! Đây là lời giải của bạn:"),
        ),
        const Divider(),
        const SizedBox(height: 10),
        if (data.steps.isNotEmpty)
          for (int i = 0; i < data.steps.length; i++)
            _buildStepRow((i + 1).toString(), data.steps[i]),
        const SizedBox(height: 10),
        if (data.latex.isNotEmpty)
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(data.latex, textStyle: const TextStyle(fontSize: 18)),
            ),
          ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text("Đáp án: ${data.result}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success)),
        ),
      ],
    );
  }

  Widget _buildStepRow(String num, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 9, backgroundColor: AppColors.primary, child: Text(num, style: const TextStyle(fontSize: 9, color: Colors.white))),
          const SizedBox(width: 8),
          Expanded(child: Text(content, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  // ================= THANH NHẬP LIỆU =================
  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 35),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatController,
              decoration: InputDecoration(
                hintText: "Bạn chưa hiểu chỗ nào?",
                fillColor: const Color(0xFFF8F9FE),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _handleSendMessage,
            child: const CircleAvatar(
              backgroundColor: Color(0xFFCAB1FF),
              radius: 24,
              child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSendMessage() {
    final text = _chatController.text.trim();
    if (text.isNotEmpty) {
      Provider.of<ChatProvider>(context, listen: false).sendUserMessage(text);
      _chatController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  // ================= APPBAR & LOADING =================
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
      title: Row(
        children: [
          const CircleAvatar(backgroundColor: AppColors.primary, radius: 16, child: Icon(Icons.auto_awesome, color: Colors.white, size: 16)),
          const SizedBox(width: 10),
          Text("Gia sư AI", style: GoogleFonts.dmSans(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 45),
      child: Row(
        children: [
          SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 10),
          Text("AI đang trả lời...", style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}