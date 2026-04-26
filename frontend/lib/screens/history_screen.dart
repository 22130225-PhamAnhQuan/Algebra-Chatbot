import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Thêm package intl để định dạng ngày tháng
import '../core/theme/app_theme.dart';
import '../providers/history_provider.dart';
import '../models/history_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = "";
  String _selectedFilter = 'Tất cả';
  final List<String> _filters = ['Tất cả', 'phuong_trinh', 'rut_gon', 'he_phuong_trinh'];

  @override
  void initState() {
    super.initState();
    // Gọi API lấy lịch sử ngay khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final historyProvider = context.watch<HistoryProvider>();

    // Logic lọc danh sách dựa trên Tìm kiếm và Filter
    List<HistoryItem> displayList = historyProvider.historyList.where((item) {
      bool matchesSearch = item.problemContent.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesFilter = _selectedFilter == 'Tất cả' || item.inputType == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          _buildHeader(context, historyProvider.historyList.length),
          _buildFilterBar(),
          Expanded(
            child: historyProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayList.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: () => historyProvider.fetchHistory(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: displayList.length,
                itemBuilder: (ctx, i) => _buildDismissibleCard(displayList[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị khi không có dữ liệu
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

  // Header màu tím với SearchBar hoạt động thật
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
              prefixIcon: const Icon(Icons.search_rounded),
              fillColor: Colors.white.withOpacity(0.2),
              filled: true,
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

  Widget _buildDismissibleCard(HistoryItem item) {
    return Dismissible(
      key: Key(item.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
      ),
      onDismissed: (direction) => context.read<HistoryProvider>().deleteHistory(item.id),
      child: _buildHistoryCard(item),
    );
  }

  // Card lịch sử sử dụng dữ liệu thật từ HistoryItem
  Widget _buildHistoryCard(HistoryItem item) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('dd/MM, HH:mm').format(item.createdAt);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100), // Đây là nơi định nghĩa viền
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Logic: Chuyển sang màn hình chi tiết và truyền dữ liệu đã giải
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Text("Q", style: TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.problemContent, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text("→ ${item.result}", style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  _buildTag(item.inputType, AppColors.primary),
                  const SizedBox(width: 15),
                  _buildInfoItem(Icons.auto_stories_outlined, "${item.steps.length} bước"),
                  const SizedBox(width: 15),
                  _buildInfoItem(Icons.access_time, timeStr),
                  const Spacer(),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa lịch sử?"),
        content: const Text("Bạn có chắc chắn muốn xóa bài giải này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
            onPressed: () {
              context.read<HistoryProvider>().deleteHistory(id);
              Navigator.pop(ctx);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
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