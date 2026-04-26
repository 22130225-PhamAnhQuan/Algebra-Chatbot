import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:algebra_chatbot/screens/chat_screen.dart';
import '../core/theme/app_theme.dart';
import '../providers/chat_provider.dart';

class SolveProblemScreen extends StatefulWidget {
  const SolveProblemScreen({super.key});

  @override
  State<SolveProblemScreen> createState() => _SolveProblemScreenState();
}

class _SolveProblemScreenState extends State<SolveProblemScreen> {
  int _tabIndex = 0; // 0: Nhập tay, 1: Chụp ảnh
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Nhập bài toán",
                style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)
            ),
            Text(
                "Chọn phương thức nhập",
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildTabSelector(theme),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              // Hiển thị nội dung tương ứng với Tab
              child: _tabIndex == 0 ? _buildManualInput(theme) : _buildCameraInput(theme),
            ),
          ),
          _buildActionButton(theme),
        ],
      ),
    );
  }

  // ================= TAB SELECTOR =================
  Widget _buildTabSelector(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? AppColors.surfaceVariant
            : AppColors.inputBackgroundDark,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _tabItem(theme, 0, Icons.keyboard_alt_outlined, "Nhập tay"),
          _tabItem(theme, 1, Icons.camera_alt_outlined, "Chụp ảnh"),
        ],
      ),
    );
  }

  Widget _tabItem(ThemeData theme, int index, IconData icon, String label) {
    bool isSelected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : AppColors.textHint, size: 20),
              const SizedBox(width: 8),
              Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                      color: isSelected ? Colors.white : AppColors.textHint
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= INTERFACE 1: NHẬP TAY =================
  Widget _buildManualInput(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        radius: 15,
                        child: Text(
                          "Q",
                          style: GoogleFonts.dmSans(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        )
                    ),
                    const SizedBox(width: 10),
                    Text("Bài toán đại số", style: theme.textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  maxLines: 5,
                  style: theme.textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: "Nhập bài toán đại số...",
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                  ),
                ),
                Text("Ví dụ: 2x² + 5x - 3 = 0", style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
        const SizedBox(height: 25),
        _buildTipBox(theme),
      ],
    );
  }

  // ================= INTERFACE 2: CHỤP ẢNH =================
  Widget _buildCameraInput(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.light ? const Color(0xFF2C254A) : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_outlined, color: Colors.white54, size: 48),
                SizedBox(height: 12),
                Text("Camera preview", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text("Hướng camera vào bài toán", style: TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _cameraButton(theme, Icons.camera_alt_outlined, "Chụp ảnh"),
            const SizedBox(width: 15),
            _cameraButton(theme, Icons.image_outlined, "Thư viện"),
          ],
        ),
        const SizedBox(height: 25),
        _buildInstructionBox(theme),
      ],
    );
  }

  // ================= COMMON COMPONENTS =================
  Widget _exampleChip(ThemeData theme, String text) {
    return ActionChip(
      label: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      backgroundColor: AppColors.primary.withOpacity(0.05),
      labelStyle: const TextStyle(color: AppColors.primary),
      side: BorderSide(color: AppColors.primary.withOpacity(0.1)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () => _controller.text = text,
    );
  }

  Widget _buildTipBox(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: AppColors.success, size: 20),
          const SizedBox(width: 13),
          Expanded(
              child: Text(
                  "Mẹo nhập liệu: Dùng ^ cho lũy thừa (x^2), * cho nhân, sqrt() cho căn bậc 2",
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.success, fontWeight: FontWeight.w500, fontSize: 15)
              )
          ),
        ],
      ),
    );
  }

  Widget _cameraButton(ThemeData theme, IconData icon, String label) {
    return Expanded(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(label, style: theme.textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionBox(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hướng dẫn chụp ảnh", style: theme.textTheme.titleSmall?.copyWith(color: AppColors.primary)),
          const SizedBox(height: 12),
          _step(theme, "1", "Chụp rõ nét, đủ ánh sáng"),
          _step(theme, "2", "Cả bài toán nằm trong khung"),
          _step(theme, "3", "Tránh bóng che và nhòe"),
        ],
      ),
    );
  }

  Widget _step(ThemeData theme, String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
              radius: 9,
              backgroundColor: AppColors.primary,
              child: Text(num, style: const TextStyle(fontSize: 10, color: Colors.white))
          ),
          const SizedBox(width: 12),
          Text(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  // ================= ACTION BUTTON (XỬ LÝ CHUYỂN TRANG) =================
  Widget _buildActionButton(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        style: theme.elevatedButtonTheme.style,
        onPressed: () {
          String problemText = _controller.text.trim();

          if (_tabIndex == 0) { // Tab Nhập tay
            if (problemText.isEmpty) {
              _showErrorSnackBar("Vui lòng nhập bài toán trước khi giải!");
              return;
            }
          } else { // Tab Chụp ảnh
            // CHÚ Ý: Đây là nơi bạn sẽ gọi logic nhận diện ảnh thực tế
            // Nếu chưa có, hãy tạm thời gán một chuỗi mặc định không rỗng
            problemText = "Bài toán từ camera: 2x + 5 = 11";
          }

          // Đảm bảo dữ liệu gửi đi cuối cùng không rỗng
          if (problemText.isEmpty) {
            _showErrorSnackBar("Nội dung bài toán không hợp lệ!");
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (_) => ChatProvider(),
                child: ChatScreen(problem: problemText),
              ),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 20),
            const SizedBox(width: 12),
            Text(_tabIndex == 0 ? "Giải ngay" : "Nhận diện & Giải"),
          ],
        ),
      ),
    );
  }

  // Hàm hiển thị thông báo lỗi nhanh
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating, // Hiển thị dạng nổi cho đẹp
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}