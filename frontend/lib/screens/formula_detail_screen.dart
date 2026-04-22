import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../models/formula_model.dart';

class FormulaDetailScreen extends StatelessWidget {
  final Formula data;

  // Constructor nhận dữ liệu từ FormulaScreen truyền sang
  const FormulaDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Chi tiết công thức",
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Tiêu đề và Khối lớp
            _buildHeaderSection(),

            const SizedBox(height: 25),

            // 2. Khung hiển thị công thức chính (To, rõ ràng)
            _buildMainFormulaBox(),

            const SizedBox(height: 35),

            // 3. Phần Giải thích lý thuyết
            if (data.explanation.isNotEmpty) ...[
              _buildSectionTitle("Giải thích chi tiết", Icons.info_outline),
              const SizedBox(height: 12),
              _buildContentBox(context, data.explanation),
              const SizedBox(height: 30),
            ],

            // 4. Phần Ví dụ minh họa
            if (data.example.isNotEmpty) ...[
              _buildSectionTitle("Ví dụ minh họa", Icons.lightbulb_outline),
              const SizedBox(height: 12),
              _buildContentBox(
                context,
                data.example,
                isExample: true,
              ),
            ],

            const SizedBox(height: 50), // Khoảng trống dưới cùng
          ],
        ),
      ),
    );
  }

  // --- Widget: Tiêu đề bài học ---
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.title,
          style: GoogleFonts.dmSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "Đại số lớp ${data.grade}",
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  // --- Widget: Khung công thức nổi bật ---
  Widget _buildMainFormulaBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: SelectableText(
        data.formula,
        textAlign: TextAlign.center,
        style: GoogleFonts.firaCode(
          fontSize: 22,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // --- Widget: Tiêu đề từng mục (Giải thích/Ví dụ) ---
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  // --- Widget: Nội dung chữ ---
  Widget _buildContentBox(BuildContext context, String content, {bool isExample = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isExample
            ? Colors.orange.withOpacity(0.05)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExample
              ? Colors.orange.withOpacity(0.2)
              : AppColors.primary.withOpacity(0.1),
        ),
      ),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 16,
          height: 1.6,
        ),
      ),
    );
  }
}