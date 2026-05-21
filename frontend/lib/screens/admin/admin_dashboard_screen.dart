// lib/screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../login_screen.dart';
import 'admin_formulas_screen.dart';
import 'admin_histories_screen.dart';
import 'admin_logs_screen.dart';
import 'admin_users_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String token;
  const AdminDashboardScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchAllAdminData(widget.token);
    });
  }

  // Hàm hiển thị Popup hỏi xác nhận đăng xuất chuẩn bảo mật
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.red.shade600, size: 24),
              const SizedBox(width: 10),
              Text(
                'Đăng xuất',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi hệ thống quản trị không?',
            style: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xFF475569)),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Đóng popup trước

                // Gọi hàm logout từ AuthProvider để xóa sạch token và session
                await context.read<AuthProvider>().logout();

                if (!mounted) return;
                // Đẩy người dùng ra màn hình Login an toàn
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(
                'Đăng xuất',
                style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Hủy',
                style: GoogleFonts.dmSans(color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context);

    // Bóc tách an toàn các trường dữ liệu thống kê từ Provider
    final overview = adminProv.stats?['overview'] ?? {};
    final aiPerf = adminProv.stats?['ai_engine_performance'] ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: adminProv.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // 1. HEADER KHU VỰC CHÀO MỪNG & ĐĂNG XUẤT
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hệ Thống Quản Trị 👋',
                        style: GoogleFonts.dmSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chào mừng trở lại, Quản trị viên',
                        style: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => _showLogoutDialog(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.logout_rounded, color: Colors.red.shade600, size: 20),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 32),

              // ==========================================
              // 2. HÀNG THẺ THỐNG KÊ NHANH
              // ==========================================
              Text(
                'Số liệu tổng quan',
                style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Học sinh',
                      value: "${overview['total_students'] ?? adminProv.users.length}",
                      icon: Icons.people_alt_rounded,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Đề toán',
                      value: "${overview['total_problems_submitted'] ?? adminProv.histories.length}",
                      icon: Icons.calculate_rounded,
                      color: const Color(0xFF059669),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Công thức',
                      value: "${overview['total_formulas_in_curriculum'] ?? adminProv.formulas.length}",
                      icon: Icons.menu_book_rounded,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ==========================================
              // 3. KHỐI HIỆU NĂNG AI ENGINE
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
                    const BoxShadow(color: Color(0xFFE2E8F0), blurRadius: 12, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    _buildPerformanceTile(
                      icon: Icons.timer_rounded,
                      iconColor: const Color(0xFF6366F1),
                      title: "Độ trễ xử lý trung bình",
                      value: "${aiPerf['avg_latency_ms'] ?? 0.0} ms",
                      valueColor: const Color(0xFF4F46E5),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      // 🚀 ĐÃ SỬA: Thay thế Colors.slate.shade100 bằng mã Hex chuẩn tránh lỗi
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
              const SizedBox(height: 32),

              // ==========================================
              // 4. LƯỚI ĐIỀU HƯỚNG CÁC PHÂN HỆ QUẢN LÝ
              // ==========================================
              Text(
                'Phân hệ quản lý chuyên sâu',
                style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildMenuCard(
                    title: 'Quản lý Học sinh',
                    subtitle: 'Khóa/mở tài khoản',
                    icon: Icons.manage_accounts_rounded,
                    gradient: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AdminUsersScreen(token: widget.token)),
                      );
                    },
                  ),
                  _buildMenuCard(
                    title: 'Công thức Toán',
                    subtitle: 'Quản lý kho SGK KNTT',
                    icon: Icons.menu_book_rounded,
                    gradient: const [Color(0xFF0EA5E9), Color(0xFF2563EB)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AdminFormulasScreen(token: widget.token)),
                      );
                    },
                  ),
                  _buildMenuCard(
                    title: 'Lịch sử Giải bài',
                    subtitle: 'Giám sát tiến độ học',
                    icon: Icons.history_edu_rounded,
                    gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AdminHistoriesScreen(token: widget.token)),
                      );
                    },
                  ),
                  _buildMenuCard(
                    title: 'AI System Logs',
                    subtitle: 'Độ trễ & Lượng Token',
                    icon: Icons.analytics_rounded,
                    gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AdminAILogsScreen(token: widget.token)),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Thẻ thống kê 3 cột gọn gàng
  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          const BoxShadow(color: Color(0xFFE2E8F0), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Widget dòng thông số hiệu năng AI
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

  // Widget Thẻ Menu Tính Năng Chuyển Trang
  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: gradient.last.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.3),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(fontSize: 11, color: Colors.white70),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}