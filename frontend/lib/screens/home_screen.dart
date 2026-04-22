// lib/screens/home_screen.dart
import 'package:algebra_chatbot/screens/solve_problem_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/theme/app_theme.dart';
import 'formula_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    const HomeContent(),
    const FormulaScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 75,
        surfaceTintColor: theme.cardTheme.color,
        elevation: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navBtn(0, Icons.home_rounded, "Trang chủ"),
            _navBtn(1, Icons.auto_awesome_motion_rounded, "Công thức"),

            // Nút Thêm (Create) nằm cố định ở giữa
            _buildCenterCreateButton(),

            _navBtn(2, Icons.history_rounded, "Lịch sử"),
            _navBtn(3, Icons.person_rounded, "Hồ sơ"),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterCreateButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SolveProblemScreen()),
        );
      },
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _navBtn(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : theme.hintColor,
              size: 26,
            ),
            Text(
              label,
              style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: isSelected ? AppColors.primary : theme.hintColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().user;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Header Gradient rút gọn (Chỉ chứa lời chào)
          _buildSimpleHeader(context, user?.name ?? 'Đang tải tên'),

          // Banner Trợ lý AI
          _buildAIBanner(context),

          _buildSectionTitle(context, "Bài toán gần đây", hasViewAll: true),
          // const RecentHistoryMiniList(),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSimpleHeader(BuildContext context, String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 65, 24, 18), // Tăng padding dưới cho thoáng
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Xin chào 👋",
                  style: GoogleFonts.dmSans(color: Colors.white.withOpacity(0.8), fontSize: 14)),
              const SizedBox(height: 6),
              Text(name,
                  style: GoogleFonts.dmSans(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text("Hãy bắt đầu giải toán thôi nào",
                  style: GoogleFonts.dmSans(color: Colors.white.withOpacity(0.8), fontSize: 20)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildAIBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 10),
      child: InkWell( // Dùng InkWell để có hiệu ứng nhấn nhẹ
        onTap: () {
          // Điều hướng sang trang SolveProblemScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SolveProblemScreen()),
          );
        },
        borderRadius: BorderRadius.circular(28),
        child: Ink( // Dùng Ink để giữ được Decoration khi dùng InkWell
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryLight, AppColors.primary],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Trợ lý AI",
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 10),
              const Text(
                "Bạn muốn giải bài gì hôm nay?",
                style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Text(
                      "Nhập hoặc chụp ảnh bài toán...",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: AppColors.primary,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, {bool hasViewAll = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 25, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          if (hasViewAll) Text("Xem tất cả", style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class RecentHistoryMiniList extends StatelessWidget {
  const RecentHistoryMiniList({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: 2,
      itemBuilder: (ctx, i) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: const Icon(Icons.history_edu, color: AppColors.primary),
          title: const Text("2x² + 5x - 3 = 0", style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text("x = 0.5, x = -3"),
          trailing: const Icon(Icons.chevron_right, size: 18),
        ),
      ),
    );
  }
}