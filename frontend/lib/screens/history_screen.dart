// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'Tất cả';
  final List<String> _filters = ['Tất cả', 'Bậc 1', 'Bậc 2', 'Hệ PT', 'Phân số'];

  // Giả lập dữ liệu từ Backend
  final List<Map<String, dynamic>> _historyData = [
    {
      'equation': '2x² + 5x - 3 = 0',
      'result': 'x = 1/2, x = -3',
      'type': 'Bậc 2',
      'steps': 6,
      'time': 'Hôm nay, 09:41',
      'color': Colors.indigo
    },
    {
      'equation': '3x + 7 = 22',
      'result': 'x = 5',
      'type': 'Bậc 1',
      'steps': 3,
      'time': 'Hôm nay, 08:30',
      'color': Colors.green
    },
    {
      'equation': '|2x - 1| = 5',
      'result': 'x = 3, x = -2',
      'type': 'Trị tuyệt đối',
      'steps': 5,
      'time': 'Hôm qua, 15:20',
      'color': Colors.pink
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          _buildHeader(context),
          _buildFilterBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _historyData.length,
              itemBuilder: (ctx, i) => _buildHistoryCard(_historyData[i]),
            ),
          ),
        ],
      ),
    );
  }

  // 1. Header màu tím Gradient
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Lịch sử", style: GoogleFonts.dmSans(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("8 bài đã giải", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                ],
              ),
              Container(
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                child: IconButton(icon: const Icon(Icons.tune_rounded, color: Colors.white), onPressed: () {}),
              )
            ],
          ),
          const SizedBox(height: 20),
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: "Tìm bài toán...",
              prefixIcon: const Icon(Icons.search_rounded),
              fillColor: Colors.white.withOpacity(0.2),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white54)),
              hintStyle: const TextStyle(color: Colors.white70),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  // 2. Thanh lọc (Filter)
  Widget _buildFilterBar() {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (ctx, i) {
          bool isSelected = _selectedFilter == _filters[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = _filters[i]),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
              ),
              alignment: Alignment.center,
              child: Text(_filters[i], style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            ),
          );
        },
      ),
    );
  }

  // 3. Card lịch sử chi tiết
  Widget _buildHistoryCard(Map<String, dynamic> data) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Icon Sigma
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: (data['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text("Q", style: TextStyle(color: data['color'], fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 15),
                // Thông tin bài toán
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['equation'], style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text("→ ${data['result']}", style: TextStyle(color: theme.hintColor, fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildTag(data['type'], data['color']),
                const SizedBox(width: 15),
                _buildInfoItem(Icons.auto_stories_outlined, "${data['steps']} bước"),
                const SizedBox(width: 15),
                _buildInfoItem(Icons.access_time, data['time']),
                const Spacer(),
                // Nút xóa màu đỏ nhạt
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 20),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}