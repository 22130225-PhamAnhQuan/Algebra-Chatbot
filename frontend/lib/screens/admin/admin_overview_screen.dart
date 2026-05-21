// lib/screens/admin/admin_overview_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class AdminOverviewScreen extends StatelessWidget {
  const AdminOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<AdminProvider>(context);
    final overview = p.stats?['overview'] ?? {};
    final aiPerf = p.stats?['ai_engine_performance'] ?? {};

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
      children: [
        // ==========================================
        // 1. PHÂN HỆ SỐ LIỆU CƠ BẢN
        // ==========================================
        Text(
          "Số liệu cơ bản",
          style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.25,
          children: [
            _buildStatCard(
              "Học sinh",
              "${overview['total_students'] ?? 0}",
              const Color(0xFF2563EB),
              Icons.people_alt_rounded,
            ),
            _buildStatCard(
              "Đề toán đã giải",
              "${overview['total_problems_submitted'] ?? 0}",
              const Color(0xFF059669),
              Icons.calculate_rounded,
            ),
            _buildStatCard(
              "Công thức gốc",
              "${overview['total_formulas_in_curriculum'] ?? 0}",
              const Color(0xFFD97706),
              Icons.menu_book_rounded,
            ),
          ],
        ),
        const SizedBox(height: 32),

        // ==========================================
        // 2. PHÂN HỆ HIỆU NĂNG ENGINE AI
        // ==========================================
        Text(
          "Hiệu năng Engine AI",
          style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: const Color(0xFFE2E8F0), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              _buildPerformanceTile(
                icon: Icons.timer_rounded, // 🚀 SỬA: Đổi sang Icon chuẩn của Flutter
                iconColor: const Color(0xFF6366F1),
                title: "Độ trễ xử lý trung bình",
                value: "${aiPerf['avg_latency_ms'] ?? 0.0} ms",
                valueColor: const Color(0xFF4F46E5),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                // 🚀 SỬA: Thay Colors.slate.shade100 bằng mã màu Hex chuẩn Color(0xFFF1F5F9)
                child: Divider(color: const Color(0xFFF1F5F9), thickness: 1.2),
              ),
              _buildPerformanceTile(
                icon: Icons.toll_rounded,
                iconColor: const Color(0xFFF59E0B),
                title: "Tổng Token tiêu thụ",
                value: "${aiPerf['total_tokens_used'] ?? 0} tokens",
                valueColor: const Color(0xFFD97706),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFFE2E8F0), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.dmSans(color: const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF334155)),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.firaCode(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }
}