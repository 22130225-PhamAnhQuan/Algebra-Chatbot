import 'dart:io';

import 'package:algebra_chatbot/providers/auth_provider.dart';
import 'package:algebra_chatbot/providers/solver_provider.dart';
import 'package:algebra_chatbot/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';

class SolveProblemScreen extends StatefulWidget {
  const SolveProblemScreen({super.key});

  @override
  State<SolveProblemScreen> createState() => _SolveProblemScreenState();
}

class _SolveProblemScreenState extends State<SolveProblemScreen> {
  int _tabIndex = 0; // 0 = camera, 1 = manual

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
            Text(
              "Nhập bài toán",
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "AI hỗ trợ giải toán đại số",
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),
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
                  ? _buildCameraInput(isDark)
                  : _buildManualInput(theme, isDark),
            ),
          ),

          _buildActionButton(),
        ],
      ),
    );
  }

  // =========================================================
  // TAB SELECTOR
  // =========================================================

  Widget _buildTabSelector(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.inputBackgroundDark
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _tabItem(
            index: 0,
            icon: Icons.camera_alt_outlined,
            label: "Chụp ảnh",
          ),
          _tabItem(
            index: 1,
            icon: Icons.keyboard_alt_outlined,
            label: "Nhập tay",
          ),
        ],
      ),
    );
  }

  Widget _tabItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _tabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tabIndex = index;
            FocusScope.of(context).unfocus();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Colors.white
                    : AppColors.textHint,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AppColors.textHint,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // MANUAL INPUT
  // =========================================================

  Widget _buildManualInput(ThemeData theme, bool isDark) {
    return Column(
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          color: isDark
              ? AppColors.surfaceDark
              : AppColors.surfaceVariant.withOpacity(0.5),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor:
                      AppColors.primary.withOpacity(0.1),
                      child: const Text(
                        "Q",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Bài toán đại số",
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                TextField(
                  controller: _controller,
                  maxLines: 8,
                  style: theme.textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    hintText:
                    "Ví dụ:\n2x^2 + 5x - 3 = 0\n\nHoặc:\ny = x^2 - 4x + 1",
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: AppColors.textHint,
                    ),
                  ),
                ),

                const Divider(),

                Text(
                  "Mẹo: dùng ^ cho lũy thừa, sqrt() cho căn bậc hai",
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        _buildInfoBox(
          color: AppColors.success,
          icon: Icons.lightbulb_outline,
          text:
          "Bạn có thể nhập phương trình, hệ phương trình, đồ thị hàm số...",
        ),
      ],
    );
  }

  // =========================================================
  // CAMERA INPUT
  // =========================================================

  Widget _buildCameraInput(bool isDark) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 260,
          decoration: BoxDecoration(
            color: const Color(0xFF2C254A),
            borderRadius: BorderRadius.circular(24),
            image: _selectedImage != null
                ? DecorationImage(
              image: FileImage(_selectedImage!),
              fit: BoxFit.cover,
            )
                : null,
          ),
          child: _selectedImage == null
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_outlined,
                  color: Colors.white54,
                  size: 50,
                ),
                SizedBox(height: 12),
                Text(
                  "Camera preview",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Hướng camera vào bài toán",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
              : null,
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            _cameraActionBtn(
              label: "Chụp ảnh",
              icon: Icons.camera_alt,
              isMain: true,
              source: ImageSource.camera,
            ),

            const SizedBox(width: 15),

            _cameraActionBtn(
              label: "Thư viện",
              icon: Icons.image,
              isMain: false,
              source: ImageSource.gallery,
            ),
          ],
        ),

        const SizedBox(height: 25),

        _buildGuideBox(),
      ],
    );
  }

  Widget _cameraActionBtn({
    required String label,
    required IconData icon,
    required bool isMain,
    required ImageSource source,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          try {
            final XFile? image = await _picker.pickImage(
              source: source,
              imageQuality: 80,
            );

            if (image == null) return;

            setState(() {
              _selectedImage = File(image.path);
            });
          } catch (e) {
            _showMsg("Không thể chọn ảnh");
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isMain
                ? AppColors.primary.withOpacity(0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isMain
                  ? AppColors.primary
                  : AppColors.textHint.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isMain
                    ? AppColors.primary
                    : AppColors.textHint,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isMain
                      ? AppColors.primary
                      : AppColors.textHint,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // GUIDE BOX
  // =========================================================

  Widget _buildGuideBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hướng dẫn chụp ảnh",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _guideStep("1", "Chụp rõ nét, đủ ánh sáng"),
          _guideStep("2", "Đặt bài toán nằm gọn trong khung"),
          _guideStep("3", "Tránh bóng che và rung tay"),
        ],
      ),
    );
  }

  Widget _guideStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 9,
            backgroundColor: AppColors.primary,
            child: Text(
              num,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // INFO BOX
  // =========================================================

  Widget _buildInfoBox({
    required Color color,
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ACTION BUTTON
  // =========================================================

  Widget _buildActionButton() {
    final solverProvider = Provider.of<SolverProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: solverProvider.isLoading
              ? null
              : () async {
            await _solveProblem(
              solverProvider,
              authProvider,
            );
          },
          child: solverProvider.isLoading
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "Đang giải bài toán...",
                style: TextStyle(color: Colors.white),
              ),
            ],
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.auto_awesome,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Text(
                _tabIndex == 1
                    ? "Giải ngay"
                    : "Nhận diện & Giải",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // SOLVE
  // =========================================================

  Future<void> _solveProblem(
      SolverProvider solverProvider,
      AuthProvider authProvider,
      ) async {
    final problemText = _controller.text.trim();

    // validate manual
    if (_tabIndex == 1 && problemText.isEmpty) {
      _showMsg("Vui lòng nhập đề bài");
      return;
    }

    // validate image
    if (_tabIndex == 0 && _selectedImage == null) {
      _showMsg("Vui lòng chọn ảnh");
      return;
    }

    try {
      final result = await solverProvider.solve(
        text: _tabIndex == 1 ? problemText : "",
        image: _tabIndex == 0 ? _selectedImage : null,
        token: authProvider.token ?? "",
      );

      if (!mounted) return;

      if (result == null) {
        _showMsg(
          solverProvider.error ??
              "Không thể giải bài toán",
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            problem: _tabIndex == 1
                ? problemText
                : "Bài toán từ hình ảnh",
            initialSolution: result,
          ),
        ),
      );
    } catch (e) {
      _showMsg(e.toString());
    }
  }

  // =========================================================
  // SNACKBAR
  // =========================================================

  void _showMsg(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }
}