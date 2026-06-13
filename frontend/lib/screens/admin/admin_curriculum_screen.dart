// lib/screens/admin/admin_formulas_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class AdminFormulasScreen extends StatefulWidget {
  final String token;
  const AdminFormulasScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<AdminFormulasScreen> createState() => _AdminFormulasScreenState();
}

class _AdminFormulasScreenState extends State<AdminFormulasScreen> {
  int? _selectedGrade; // null = Tất cả khối lớp

  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context);
    final formulas = adminProv.formulas;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // ==========================================
          // 1. HEADER GRADIENT GIỐNG HỆT TRANG LOG AI
          // ==========================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 56, left: 20, right: 20, bottom: 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Công Thức Toán học',
                      style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sách Kết nối tri thức với cuộc sống',
                      style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ==========================================
          // 2. BỘ LỌC KHỐI LỚP (FILTER CHIPS)
          // ==========================================
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildGradeChip('Tất cả', null, adminProv),
                  const SizedBox(width: 8),
                  _buildGradeChip('Lớp 6', 6, adminProv),
                  const SizedBox(width: 8),
                  _buildGradeChip('Lớp 7', 7, adminProv),
                  const SizedBox(width: 8),
                  _buildGradeChip('Lớp 8', 8, adminProv),
                  const SizedBox(width: 8),
                  _buildGradeChip('Lớp 9', 9, adminProv),
                ],
              ),
            ),
          ),

          // ==========================================
          // 3. DANH SÁCH CÔNG THỨC
          // ==========================================
          Expanded(
            child: adminProv.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
                : formulas.isEmpty
                ? Center(
              child: Text(
                'Chưa có công thức nào cho lớp này',
                style: GoogleFonts.dmSans(color: const Color(0xFF64748B)),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: formulas.length,
              itemBuilder: (context, index) {
                final f = formulas[index];
                return _buildFormulaCard(f, index, adminProv);
              },
            ),
          ),
        ],
      ),
      // Nút Thêm mới (FAB)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Mở form thêm mới
        },
        backgroundColor: const Color(0xFF4F46E5),
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Thêm công thức',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // Widget dựng Thẻ công thức chuẩn UI mới
  Widget _buildFormulaCard(dynamic f, int index, AdminProvider adminProv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE2E8F0).withOpacity(0.6),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Label Khối lớp
                  _buildTag(
                    'Toán ${f['grade']}',
                    const Color(0xFFECFDF5),
                    const Color(0xFF059669),
                  ),
                  const SizedBox(width: 8),
                  // Label Category (Đại số / Hình học)
                  _buildTag(
                    f['category'] ?? 'Đại số',
                    const Color(0xFFEFF6FF),
                    const Color(0xFF2563EB),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => adminProv.removeFormula(widget.token, f['id'], index),
                icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 20),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            f['title'] ?? 'Tiêu đề trống',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          // Khối Code Công thức
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              f['formula'] ?? '',
              style: GoogleFonts.firaCode(
                fontSize: 13,
                color: const Color(0xFF4F46E5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget bổ trợ Tag
  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  // Widget bổ trợ Grade Chip
  Widget _buildGradeChip(String label, int? gradeValue, AdminProvider adminProv) {
    bool isSelected = _selectedGrade == gradeValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        setState(() => _selectedGrade = gradeValue);
        adminProv.filterFormulasByGrade(widget.token, gradeValue);
      },
      selectedColor: const Color(0xFF4F46E5),
      backgroundColor: Colors.white,
      labelStyle: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? Colors.white : const Color(0xFF64748B),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0)),
      showCheckmark: false,
    );
  }
}