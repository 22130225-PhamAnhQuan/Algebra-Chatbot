import 'package:algebra_chatbot/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

class SolveProblemScreen extends StatefulWidget {
  const SolveProblemScreen({super.key});

  @override
  State<SolveProblemScreen> createState() => _SolveProblemScreenState();
}

class _SolveProblemScreenState extends State<SolveProblemScreen> {
  int _tabIndex = 0; // 0: Nhập tay, 1: Chụp ảnh
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        // Cố định màu AppBar theo Theme
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Nhập bài toán",
                // Dùng textTheme từ theme và ghi đè màu
                style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)
            ),
            Text(
                "Chọn phương thức nhập",
                // Dùng textTheme cho bodySmall và ghi đè màu
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
        // Thích ứng màu nền Tab theo Brightness
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
              // Sử dụng IconTheme để quản lý màu icon
              Icon(icon, color: isSelected ? Colors.white : AppColors.textHint, size: 20),
              const SizedBox(width: 8),
              Text(
                  label,
                  // Dùng labelLarge và ghi đè màu
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
          // Dùng CardTheme định nghĩa trong AppTheme
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // --- CẬP NHẬT TỪ ICON SANG CHỮ 'Q' ---
                    CircleAvatar(
                      // Nền mờ cùng tông primary
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        radius: 15,
                        child: Text(
                          "Q",
                          style: GoogleFonts.dmSans( // Dùng font DM Sans cho 'Q'
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800, // Đậm hơn để nổi bật
                            fontSize: 16, // Kích thước chữ 'Q'
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
                  maxLines: 5,
                  // Tự động áp dụng style từ InputDecorationTheme
                  style: theme.textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: "Nhập bài toán đại số...",
                    // Ghi đè border của theme để không có khung
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent, // Nền trong suốt
                  ),
                ),
                Text("Ví dụ: 2x² + 5x - 3 = 0", style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
        const SizedBox(height: 25),
        // labelSmall từ TextTheme và màu phụ
        Text("VÍ DỤ NHANH", style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _exampleChip(theme, "2x² + 5x - 3 = 0"),
            _exampleChip(theme, "3x + 7 = 22"),
            _exampleChip(theme, "|2x - 1| = 5"),
            _exampleChip(theme, "x/2 + x/3 = 5"),
          ],
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
            // Cố định màu camera preview hoặc dùng surfaceDark
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
      // Dùng TextStyle nhẹ nhàng cho ActionChip
      label: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      // Sử dụng AppColors trực tiếp để phối màu phụ
      backgroundColor: AppColors.primary.withOpacity(0.05),
      labelStyle: const TextStyle(color: AppColors.primary),
      // Viền mờ cùng tông primary
      side: BorderSide(color: AppColors.primary.withOpacity(0.1)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () => _controller.text = text,
    );
  }

  Widget _buildTipBox(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Dùng màu success với opacity thấp cho nền
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
                  // bodySmall phối với màu success
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
            // Dùng màu divider từ theme
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
        // Màu nền phụ tông primary
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // titleSmall phối màu primary
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
          // bodyMedium mặc định
          Text(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildActionButton(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        style: theme.elevatedButtonTheme.style,
        onPressed: () {
          // 1. Lấy dữ liệu bài toán
          String problemText = _controller.text.trim();

          // 2. Kiểm tra nếu là Tab Nhập tay mà chưa nhập gì thì báo lỗi
          if (_tabIndex == 0 && problemText.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Vui lòng nhập bài toán trước khi giải!"),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }

          // 3. Nếu là Tab Chụp ảnh (Hiện tại Quan làm demo hoặc đã có ảnh)
          if (_tabIndex == 1) {
            // Tạm thời gán một ví dụ nếu Quan chưa làm phần nhận diện ảnh thật
            problemText = "Hình ảnh bài toán từ Camera";
          }

          // 4. CHUYỂN TRANG
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(problem: problemText),
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
}