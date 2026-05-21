import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../core/theme/app_theme.dart';
import '../providers/chat_provider.dart';
import '../models/solution_model.dart';
import '../core/constants/api_config.dart';

class ChatScreen extends StatefulWidget {
  final String problem;
  final SolutionModel? initialSolution;

  const ChatScreen({
    super.key,
    required this.problem,
    this.initialSolution,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class GraphImage extends StatelessWidget {
  final String base64Image;

  const GraphImage({super.key, required this.base64Image});

  @override
  Widget build(BuildContext context) {
    final bytes = base64Decode(base64Image);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          bytes,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Khởi tạo dữ liệu ngay khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ChatProvider>(context, listen: false);
      if (widget.initialSolution != null) {
        // Ưu tiên dùng kết quả có sẵn từ màn hình trước
        provider.setInitialSolution(widget.problem, widget.initialSolution!);
      } else {
        // Nếu không có (ví dụ vào từ lịch sử) thì mới giải lại
        provider.solveProblem(widget.problem);
      }
    });
  }

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context, isDark),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.messages.length + (provider.isSending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.messages.length) {
                      return _buildLoadingState(isDark);
                    }

                    final msg = provider.messages[index];
                    if (msg.sender == 'USER') {
                      return _buildUserBubble(msg.content, isDark, imageUrl: msg.imageUrl);
                    } else {
                      // Logic: Tin nhắn BOT ở index 1 thường chứa lời giải chi tiết
                      bool showSolution = (index == 1 && provider.solutionData != null);
                      return _buildBotBubble(msg.content, isDark, isSolution: showSolution);
                    }
                  },
                );
              },
            ),
          ),
          _buildChatInput(isDark),
        ],
      ),
    );
  }

  // ================= 1. APP BAR =================
  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
        onPressed: () => Navigator.pop(context, true),
      ),
      title: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 16,
            child: Icon(Icons.auto_awesome, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Text(
            "Gia sư AI",
            style: GoogleFonts.dmSans(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  // ================= 2. BONG BÓNG CHAT =================
  Widget _buildUserBubble(String text, bool isDark, {String? imageUrl}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Nếu có ảnh thì hiện ảnh lên trước bubble chữ
            if (imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    "${ApiConfig.baseUrl}$imageUrl",
                    width: MediaQuery.of(context).size.width * 0.6,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                  ),
                ),
              ),

            // Bubble chứa nội dung text (đề bài)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: isDark ? AppColors.primary.withOpacity(0.2) : const Color(0xFFF3E9FF),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotBubble(String content, bool isDark, {bool isSolution = false}) {
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
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: isSolution ? _buildSolutionContent(isDark) : _buildSimpleText(content, isDark),
            ),
          ),
        ],
      ),
    );
  }

  // ================= 3. NỘI DUNG LỜI GIẢI =================
  Widget _buildSimpleText(String text, bool isDark) {
    return Math.tex(
      text,
      textStyle: TextStyle(fontSize: 15, color: isDark ? Colors.white : Colors.black87, height: 1.4),
      onErrorFallback: (err) => Text(text, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
    );
  }

  Widget _buildSolutionContent(bool isDark) {
    final provider = Provider.of<ChatProvider>(context);
    final data = provider.solutionData;
    if (data == null) return const Text("Đang tải lời giải...");

    if (data.isGraph) {
      return _buildGraphSolution(data, isDark);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Lời dẫn thân thiện (Giống ảnh 2)
        Text(
          "Tôi sẽ giải phương trình: **${widget.problem}** cho bạn nhé! Đây là lời giải chi tiết từng bước:",
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimary,
            fontSize: 15,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 15),

        if (data.image != null && data.image!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                base64Decode(data.image!),
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],

        const SizedBox(height: 15),

        // 2. Khung "Giải từng bước"
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20), // Bo góc mềm mại
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
            boxShadow: [
              if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header của khung
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text("Giải từng bước", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 16),

              // Render danh sách các bước
              if (data.steps.isNotEmpty)
                for (int i = 0; i < data.steps.length; i++)
                  _buildStepRow((i + 1).toString(), data.steps[i], isDark),

              const SizedBox(height: 8),

              // Bước cuối cùng: Nút xanh Kết quả (Giống bước 6 trong ảnh 2)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(6), // Ô vuông nhỏ tích xanh
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Kết quả: ${data.result}",
                      style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGraphSolution(
      SolutionModel data,
      bool isDark,
      ) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          "📊 Đồ thị hàm số",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 16),

        // IMAGE
        if (data.hasImage)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              base64Decode(data.image!),
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),

        const SizedBox(height: 20),

        // STEPS
        ...data.steps.map((step) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    "${step.stepNumber}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    step.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark
                          ? Colors.white70
                          : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            "Kết quả: ${data.result}",
            style: const TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepRow(String num, dynamic stepData, bool isDark) {
    String description = "";
    String latexStr = "";

    // ================= 1. BÓC TÁCH DỮ LIỆU (SMART PARSER) =================
    // Nếu bị lỗi Model ép thành String: "{step_number: 1, description: ..., latex: ...}"
    if (stepData is String) {
      // Dùng Regex để tự động gắp chữ ra khỏi chuỗi lỗi
      final descMatch = RegExp(r'description:\s*(.*?),\s*latex:').firstMatch(stepData);
      final latexMatch = RegExp(r'latex:\s*(.*?)\}?$').firstMatch(stepData);

      if (descMatch != null) description = descMatch.group(1)?.trim() ?? "";
      if (latexMatch != null) latexStr = latexMatch.group(1)?.trim() ?? "";

      // Fallback nếu Regex không tìm thấy
      if (description.isEmpty && latexStr.isEmpty) description = stepData;
    }
    // Nếu là Map chuẩn (JSON gốc)
    else if (stepData is Map) {
      description = stepData['description']?.toString() ?? "";
      latexStr = stepData['latex']?.toString() ?? "";
    }
    // Nếu là Object Model (StepModel)
    else {
      try {
        description = stepData.description ?? "";
        latexStr = stepData.latex ?? "";
      } catch (e) {
        description = stepData.toString();
      }
    }

    // ================= 2. LÀM SẠCH LATEX CHO FLUTTER MATH =================
    latexStr = latexStr.replaceAll(r'\begin{align*}', '')
        .replaceAll(r'\end{align*}', '')
        .replaceAll(r'\begin{align}', '')
        .replaceAll(r'\end{align}', '')
        .replaceAll(r'$', '')
        .trim();

    // ================= 3. RENDER GIAO DIỆN =================
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.primary,
              child: Text(num, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold))
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (description.isNotEmpty)
                  Text(
                      description,
                      style: TextStyle(fontSize: 15, color: isDark ? Colors.white70 : Colors.black87, height: 1.4)
                  ),

                if (latexStr.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Math.tex(
                      latexStr,
                      textStyle: TextStyle(fontSize: 15, color: isDark ? Colors.white : Colors.black87),
                      onErrorFallback: (err) => Text(latexStr, style: const TextStyle(color: Colors.red)),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= 4. NHẬP LIỆU & LOADING =================
  Widget _buildChatInput(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 35),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: "Bạn chưa hiểu chỗ nào?",
                hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                fillColor: isDark ? AppColors.inputBackgroundDark : const Color(0xFFF8F9FE),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _handleSendMessage,
            child: CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 24,
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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

  Widget _buildLoadingState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 45),
      child: Row(
        children: [
          const SizedBox(height: 12, width: 12, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
          const SizedBox(width: 12),
          Text(
              "AI đang giải đáp...",
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey, fontStyle: FontStyle.italic)
          ),
        ],
      ),
    );
  }
}