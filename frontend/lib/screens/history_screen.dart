import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_theme.dart';
import '../providers/history_provider.dart';
import '../models/history_model.dart';
import '../models/solution_model.dart';
import 'chat_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = "";
  String _selectedFilter = 'Tất cả';

  // Danh sách các tab hiển thị trên UI
  final List<String> _filterKeys = [
    'Tất cả',
    'Phương trình',
    'Rút gọn',
    'Hệ phương trình',
    'Số học',
    'Nhân tử hóa',
  ];

  // Map từ UI Text sang key của Backend để lọc
  final Map<String, String> _filters = {
    'Tất cả': 'all',
    'Phương trình': 'phuong_trinh',
    'Rút gọn': 'rut_gon',
    'Hệ phương trình': 'he_phuong_trinh',
    'Số học': 'so_hoc',
    'Nhân tử hóa': 'nhan_tu',
  };

  String _getFilterLabel(String key) {
    switch (key) {
      case 'phuong_trinh': return 'Phương trình';
      case 'rut_gon': return 'Rút gọn';
      case 'he_phuong_trinh': return 'Hệ phương trình';
      case 'so_hoc': return 'Số học';
      case 'nhan_tu': return 'Nhân tử hóa';
      default: return key;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final historyProvider = context.watch<HistoryProvider>();

    // Logic lọc danh sách theo Search và Filter
    List<HistoryItem> displayList = historyProvider.historyList.where((item) {
      bool matchesSearch = item.problemContent.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesFilter = _selectedFilter == 'Tất cả' || item.inputType == _filters[_selectedFilter];
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          // 1. Header (Tổng số bài + Thanh tìm kiếm)
          _buildHeader(context, historyProvider.historyList.length),

          // 2. Thanh Filter (Tuyệt đối không được thiếu dòng này)
          _buildFilterBar(),

          // 3. Danh sách Card lịch sử
          Expanded(
            child: historyProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : displayList.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => historyProvider.fetchHistory(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: displayList.length,
                itemBuilder: (ctx, i) => _buildDismissibleCard(displayList[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("Chưa có lịch sử giải bài", style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int total) {
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
                  Text("$total bài đã giải", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: () => context.read<HistoryProvider>().fetchHistory(),
              )
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: "Tìm bài toán...",
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
              fillColor: Colors.white.withOpacity(0.2),
              filled: true,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white54)),
              hintStyle: const TextStyle(color: Colors.white70),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 65,
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _filterKeys.length,
        itemBuilder: (ctx, i) {
          String key = _filterKeys[i];
          bool isSelected = _selectedFilter == key;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = key;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : (isDark ? AppColors.surfaceVariant : Colors.white),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? Colors.white24 : Colors.grey.shade300),
                  width: 1.5,
                ),
                boxShadow: isSelected && !isDark
                    ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                    : [],
              ),
              alignment: Alignment.center,
              child: Text(
                key,
                style: TextStyle(
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.grey.shade700),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDismissibleCard(HistoryItem item) {
    return Dismissible(
      key: Key(item.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
      ),
      onDismissed: (direction) => context.read<HistoryProvider>().deleteHistory(item.id),
      child: _buildHistoryCard(item),
    );
  }

  Widget _buildHistoryCard(HistoryItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr = DateFormat('dd/MM, HH:mm').format(item.createdAt);

    return Card(
      elevation: 0,
      color: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final oldSolution = SolutionModel(
            result: item.result,
            latex: item.latex,
            steps: item.steps,
          );

          // Chuyển sang màn hình Chat
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                problem: item.problemContent,
                initialSolution: oldSolution,
              ),
            ),
          );

          // Tự động làm mới lịch sử khi quay về màn hình này
          if (context.mounted) {
            context.read<HistoryProvider>().fetchHistory();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Text("Q", style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cắt chữ nếu dài quá 1 dòng
                        Text(
                            item.problemContent,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis
                        ),
                        const SizedBox(height: 4),
                        // Cắt chữ nếu AI trả về result quá dài
                        Text(
                            "→ ${item.result}",
                            style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white38 : Colors.grey),
                ],
              ),

              // Đường phân cách mỏng
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, thickness: 0.5),
              ),

              // Hàng thông tin phụ bên dưới
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildTag(_getFilterLabel(item.inputType), AppColors.primary),
                      const SizedBox(width: 12),
                      _buildInfoItem(Icons.auto_stories_outlined, "${item.steps.length} bước"),
                      const SizedBox(width: 12),
                      _buildInfoItem(Icons.access_time, timeStr),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _showDeleteDialog(item.id),
                    child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade300, size: 20),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(int id) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Xóa bài toán?"),
        content: const Text("Bạn có chắc chắn muốn xóa bài giải này khỏi lịch sử không?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Hủy", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
            ),
            onPressed: () {
              context.read<HistoryProvider>().deleteHistory(id);
              Navigator.pop(ctx);
            },
            child: const Text("Xóa"),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}