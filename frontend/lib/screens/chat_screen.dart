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

  const ChatScreen({super.key, required this.problem, this.initialSolution});

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
        child: Image.memory(bytes, fit: BoxFit.contain),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ChatProvider>(context, listen: false);
      if (widget.initialSolution != null) {
        provider.setInitialSolution(widget.problem, widget.initialSolution!);
      } else {
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
                WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _scrollToBottom(),
                );

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount:
                  provider.messages.length + (provider.isSending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.messages.length) {
                      return _buildLoadingState(isDark);
                    }

                    final msg = provider.messages[index];
                    if (msg.sender == 'USER') {
                      return _buildUserBubble(
                        msg.content,
                        isDark,
                        imageUrl: msg.imageUrl,
                      );
                    } else {
                      bool showSolution =
                          (index == 1 ||
                              (index ==
                                  provider.messages.indexOf(
                                    provider.messages.firstWhere(
                                          (m) => m.sender == 'BOT',
                                    ),
                                  ))) &&
                              provider.solutionData != null;
                      return _buildBotBubble(
                        msg.content,
                        isDark,
                        isSolution: showSolution,
                      );
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

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? Colors.white : Colors.black87,
        ),
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

  Widget _buildUserBubble(String text, bool isDark, {String? imageUrl}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    "${ApiConfig.baseUrl}$imageUrl",
                    width: MediaQuery.of(context).size.width * 0.6,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 50,
                    ),
                  ),
                ),
              ),

            // Bubble chứa nội dung text (đề bài)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primary.withOpacity(0.2)
                    : const Color(0xFFF3E9FF),
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

  Widget _buildBotBubble(
      String content,
      bool isDark, {
        bool isSolution = false,
      }) {
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
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: isSolution
                  ? _buildSolutionContent(isDark)
                  : _buildSimpleText(content, isDark),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _parseTextWithMath(String text, bool isDark) {
    List<Widget> widgets = [];

    // Regex bắt trọn \[...\], \(...\), $$...$$, $...$
    final regex = RegExp(
      r'\\\[(.*?)\\\]|\\\((.*?)\\\)|\$\$(.*?)\$\$|\$(.*?)\$',
      dotAll: true,
    );

    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        widgets.add(Text(
          text.substring(lastIndex, match.start),
          style: TextStyle(fontSize: 15, color: isDark ? Colors.white : Colors.black87, height: 1.4),
        ));
      }

      String mathContent = match.group(1) ?? match.group(2) ?? match.group(3) ?? match.group(4) ?? "";

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
          child: Math.tex(
            mathContent.trim(),
            textStyle: TextStyle(fontSize: 15, color: isDark ? Colors.white : Colors.black87),
            onErrorFallback: (err) => Text(
              mathContent,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      widgets.add(Text(
        text.substring(lastIndex),
        style: TextStyle(fontSize: 15, color: isDark ? Colors.white : Colors.black87, height: 1.4),
      ));
    }

    return widgets.isEmpty
        ? [Text(text, style: TextStyle(fontSize: 15, color: isDark ? Colors.white : Colors.black87))]
        : widgets;
  }

  Widget _buildSimpleText(String text, bool isDark) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: _parseTextWithMath(text, isDark),
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
        RichText(
          text: TextSpan(
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15, height: 1.4),
            children: [
              const TextSpan(text: "Tôi sẽ giải: "),
              TextSpan(
                text: widget.problem,
                style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: AppColors.primary),
              ),
              const TextSpan(text: " cho bạn nhé! Đây là lời giải chi tiết từng bước:"),
            ],
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
          const SizedBox(height: 15),
        ],

        // Khung "Giải từng bước"
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    "Giải từng bước",
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (data.steps.isNotEmpty) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.steps.expand<Widget>((step) {
                    String stepText = step.latex.isNotEmpty ? step.latex : step.description;
                    String cleanText = stepText.trim();

                    List<String> extractedLines = [];

                    if (cleanText.startsWith('[') && cleanText.endsWith(']')) {
                      try {
                        String safeText = cleanText.replaceAll(r'\', r'\\').replaceAll(r'\\\\', r'\\');
                        List<dynamic> parsedList = jsonDecode(safeText);
                        extractedLines = parsedList.map((item) => item.toString()).toList();
                      } catch (e) {
                        debugPrint("Lỗi parse JSON trong ChatScreen: $e");
                        extractedLines = [cleanText];
                      }
                    } else {
                      extractedLines = cleanText.split('\n');
                    }

                    return extractedLines
                        .where((line) => line.trim().isNotEmpty)
                        .map((line) => _buildStepRow(line.trim(), isDark))
                        .toList();

                  }).toList(),
                )
              ] else
                const Text("Không có bước giải"),

              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          "Kết quả: ",
                          style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 15),
                        ),

                        (data.image != null && data.image!.isNotEmpty)
                            ? const Text(
                          "Đồ thị như hình vẽ bên trên",
                          style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 15),
                        )
                            : Math.tex(
                          data.result.replaceAll(r'$', '').trim(),
                          textStyle: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 15),
                          onErrorFallback: (err) => Text(
                            data.result,
                            style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ],
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

  Widget _buildGraphSolution(SolutionModel data, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...data.steps.map((step) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primary,
                  child: Text("${step.stepNumber}", style: const TextStyle(color: Colors.white, fontSize: 11)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStepRow(
                    step.latex.isNotEmpty ? step.latex : step.description,
                    isDark,
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.success.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              if (data.hasImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    base64Decode(data.image!),
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatInput(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 35),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: "Bạn chưa hiểu chỗ nào?",
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                fillColor: isDark
                    ? AppColors.inputBackgroundDark
                    : const Color(0xFFF8F9FE),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _handleSendMessage,
            child: CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 24,
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
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
          const SizedBox(
            height: 12,
            width: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "AI đang giải đáp...",
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(String rawLine, bool isDark) {
    String cleanContent = rawLine
        .replaceAll(r'\[', '')  // Xóa mở ngoặc vuông LaTeX
        .replaceAll(r'\]', '')  // Xóa đóng ngoặc vuông LaTeX
        .replaceAll(r'\(', '')  // Xóa mở ngoặc tròn LaTeX
        .replaceAll(r'\)', '')  // Xóa đóng ngoặc tròn LaTeX
        .replaceAll(r'\begin{align*}', '')
        .replaceAll(r'\end{align*}', '')
        .replaceAll(r'\begin{align}', '')
        .replaceAll(r'\end{align}', '')
        .replaceAll(r'$', '')
        .trim();

    // Loại bỏ chữ "c" vô nghĩa do parser cũ sinh ra
    if (cleanContent.isEmpty || cleanContent == 'c') return const SizedBox.shrink();

    RegExp textRegex = RegExp(r'\\text\{([^}]+)\}');
    String textDescription = "";

    if (textRegex.hasMatch(cleanContent)) {
      final match = textRegex.firstMatch(cleanContent);
      textDescription = match?.group(1)?.trim() ?? "";
      cleanContent = cleanContent.replaceAll(textRegex, '').trim();
    }

    bool isMath = cleanContent.contains(r'\') ||
        cleanContent.contains('^') ||
        cleanContent.contains('_') ||
        cleanContent.contains('=') ||
        cleanContent.contains('&') ||
        cleanContent.contains('<') ||
        cleanContent.contains('>');

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (textDescription.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                textDescription,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),

          if (cleanContent.isNotEmpty && isMath)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(
                cleanContent,
                textStyle: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.4
                ),
                onErrorFallback: (err) => Text(
                  cleanContent,
                  style: TextStyle(fontSize: 15, color: isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            )
          else if (cleanContent.isNotEmpty)
            Text(
              cleanContent,
              softWrap: true,
              style: TextStyle(fontSize: 15, height: 1.4, color: isDark ? Colors.white70 : Colors.black87),
            ),
        ],
      ),
    );
  }
}