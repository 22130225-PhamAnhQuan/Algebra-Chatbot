import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

// Import các thành phần của dự án Quan
import 'package:algebra_chatbot/providers/solver_provider.dart';
import 'package:algebra_chatbot/providers/auth_provider.dart';
import 'package:algebra_chatbot/screens/chat_screen.dart';
import '../core/theme/app_theme.dart';

class SolveProblemScreen extends StatefulWidget {
  const SolveProblemScreen({super.key});

  @override
  State<SolveProblemScreen> createState() => _SolveProblemScreenState();
}

class _SolveProblemScreenState extends State<SolveProblemScreen> {
  int _tabIndex = 0; // 0: Nhập tay, 1: Chụp ảnh
  File? _selectedImage;
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nhập bài toán",
                style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            Text("Chọn phương thức nhập",
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildTabSelector(isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _tabIndex == 0
                  ? _buildManualInput(theme, isDark)
                  : _buildCameraInput(isDark),
            ),
          ),
          _buildActionButton(theme),
        ],
      ),
    );
  }

  // ================= 1. TAB SELECTOR =================
  Widget _buildTabSelector(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputBackgroundDark : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _tabItem(0, Icons.keyboard_alt_outlined, "Nhập tay"),
          _tabItem(1, Icons.camera_alt_outlined, "Chụp ảnh"),
        ],
      ),
    );
  }

  Widget _tabItem(int index, IconData icon, String label) {
    bool isSelected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _tabIndex = index;
          FocusScope.of(context).unfocus(); // Ẩn bàn phím khi chuyển tab
        }),
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
              Text(label,
                  style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textHint,
                      fontWeight: FontWeight.bold
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // ================= 2. NHẬP TAY (Manual) =================
  Widget _buildManualInput(ThemeData theme, bool isDark) {
    return Column(
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceVariant.withOpacity(0.5),
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
                      child: const Text("Q", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Text("Bài toán đại số", style: theme.textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _controller,
                  maxLines: 6,
                  style: theme.textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: "Nhập bài toán của bạn...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: AppColors.textHint),
                  ),
                ),
                const Divider(),
                Text("Ví dụ: 2x^2 + 5x - 3 = 0",
                    style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildInfoBox(AppColors.success, Icons.lightbulb_outline, "Mẹo: Dùng ^ cho lũy thừa (x^2), * cho nhân, sqrt() cho căn bậc 2."),
      ],
    );
  }

  // ================= 3. CHỤP ẢNH (Camera) =================
  Widget _buildCameraInput(bool isDark) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: const Color(0xFF2C254A), // Tím than đồng bộ ảnh mẫu Quan gửi
            borderRadius: BorderRadius.circular(24),
            image: _selectedImage != null
                ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                : null,
          ),
          child: _selectedImage == null ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_outlined, color: Colors.white54, size: 48),
                SizedBox(height: 12),
                Text("Camera preview", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text("Hướng camera vào bài toán", style: TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ) : null,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _cameraActionBtn("Chụp ảnh", Icons.camera_alt, true, ImageSource.camera),
            const SizedBox(width: 15),
            _cameraActionBtn("Thư viện", Icons.image, false, ImageSource.gallery),
          ],
        ),
        const SizedBox(height: 25),
        _buildGuideBox(),
      ],
    );
  }

  Widget _cameraActionBtn(String label, IconData icon, bool isMain, ImageSource source) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          final XFile? image = await _picker.pickImage(source: source, imageQuality: 80);
          if (image != null) setState(() => _selectedImage = File(image.path));
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isMain ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isMain ? AppColors.primary : AppColors.textHint.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: isMain ? AppColors.primary : AppColors.textHint),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: isMain ? AppColors.primary : AppColors.textHint, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  // ================= 4. COMMON COMPONENTS =================
  Widget _buildInfoBox(Color color, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildGuideBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Hướng dẫn chụp ảnh", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _guideStep("1", "Chụp rõ nét, đủ ánh sáng"),
          _guideStep("2", "Cả bài toán nằm trong khung"),
          _guideStep("3", "Tránh bóng che và nhòe"),
        ],
      ),
    );
  }

  Widget _guideStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        CircleAvatar(radius: 9, backgroundColor: AppColors.primary, child: Text(num, style: const TextStyle(fontSize: 10, color: Colors.white))),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 13)),
      ]),
    );
  }

  // ================= 5. ACTION BUTTON =================
  Widget _buildActionButton(ThemeData theme) {
    final solverProvider = Provider.of<SolverProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          onPressed: solverProvider.isLoading ? null : () async {
            String? pText = _tabIndex == 0 ? _controller.text.trim() : null;
            if (_tabIndex == 0 && pText!.isEmpty) { _showMsg("Vui lòng nhập đề bài!"); return; }
            if (_tabIndex == 1 && _selectedImage == null) { _showMsg("Vui lòng chụp ảnh!"); return; }

            try {
              final result = await solverProvider.solve(
                text: pText,
                image: _tabIndex == 1 ? _selectedImage : null,
                token: authProvider.token ?? "",
              );

              if (result != null && mounted) {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    problem: _tabIndex == 0 ? pText! : "Bài toán qua hình ảnh",
                    initialSolution: result,
                  ),
                ));
              }
            } catch (e) {
              _showMsg(e.toString());
            }
          },
          child: solverProvider.isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white),
              const SizedBox(width: 10),
              Text(_tabIndex == 0 ? "Giải ngay" : "Nhận diện & Giải", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  void _showMsg(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.error));
  }
}