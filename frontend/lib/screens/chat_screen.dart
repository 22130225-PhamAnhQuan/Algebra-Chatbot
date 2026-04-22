import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final String problem; // Nhận đề bài từ màn hình trước truyền sang
  const ChatScreen({super.key, required this.problem});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _chatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildUserQuestion(widget.problem),
                const SizedBox(height: 20),
                _buildBotResponse(),
              ],
            ),
          ),
          _buildChatInput(theme),
        ],
      ),
    );
  }

  // ================= APPBAR =================
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black54),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 18,
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Algebra AI", style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  const Text("Đang hoạt động", style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.more_vert, color: Colors.black54), onPressed: () {}),
      ],
    );
  }

  // ================= USER QUESTION BUBBLE =================
  Widget _buildUserQuestion(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E9FF),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Σ", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            const SizedBox(width: 10),
            const Icon(Icons.copy_rounded, size: 14, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  // ================= BOT RESPONSE =================
  Widget _buildBotResponse() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lời dẫn của Bot
        Container(
          margin: const EdgeInsets.only(left: 45),
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: const Text("nhé! Đây là lời giải chi tiết từng bước:"),
        ),
        const SizedBox(height: 12),

        // Khung lời giải chi tiết
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 16,
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
                        SizedBox(width: 8),
                        Text("Giải từng bước", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildStep("1", "Xác định hệ số: a = 2, b = 5, c = -3"),
                    _buildStep("2", "Tính delta: Δ = b² - 4ac = 5² - 4×2×(-3) = 25 + 24 = 49"),
                    _buildStep("3", "Vì Δ = 49 > 0 → Phương trình có 2 nghiệm phân biệt"),
                    _buildStep("4", "x₁ = (-b + √Δ) / 2a = (-5 + 7) / 4 = 2/4 = 1/2"),
                    _buildStep("5", "x₂ = (-b - √Δ) / 2a = (-5 - 7) / 4 = -12/4 = -3"),
                    _buildStep("6", "✅ Kết quả: x₁ = 1/2 và x₂ = -3"),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Action buttons dưới câu trả lời
        Padding(
          padding: const EdgeInsets.only(left: 45, top: 10),
          child: Row(
            children: [
              _botAction(Icons.thumb_up_alt_outlined, "Hữu ích"),
              _botAction(Icons.thumb_down_alt_outlined, "Không đúng"),
              _botAction(Icons.copy, "Sao chép"),
            ],
          ),
        ),

        // Câu hỏi gợi ý
        const Padding(
          padding: EdgeInsets.only(left: 45, top: 20),
          child: Center(child: Text("Câu hỏi gợi ý", style: TextStyle(color: Colors.grey, fontSize: 12))),
        ),
        _buildSuggestBtn("Giải thích cách tính delta?"),
        _buildSuggestBtn("Cho ví dụ tương tự"),
        _buildSuggestBtn("Phương trình có nghiệm kép là gì?"),
      ],
    );
  }

  Widget _buildStep(String num, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 10, backgroundColor: AppColors.primary, child: Text(num, style: const TextStyle(fontSize: 10, color: Colors.white))),
          const SizedBox(width: 10),
          Expanded(child: Text(content, style: const TextStyle(fontSize: 13, height: 1.5))),
        ],
      ),
    );
  }

  Widget _botAction(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSuggestBtn(String text) {
    return Container(
      margin: const EdgeInsets.only(left: 45, top: 10),
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(color: Colors.black87, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // ================= INPUT FIELD =================
  Widget _buildChatInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatController,
              decoration: InputDecoration(
                hintText: "Hỏi thêm về bài toán...",
                fillColor: const Color(0xFFF8F9FE),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: const Color(0xFFCAB1FF),
            radius: 25,
            child: const Icon(Icons.send_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}