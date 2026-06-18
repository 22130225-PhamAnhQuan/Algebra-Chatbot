import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_theme.dart';
import '../providers/history_provider.dart';
import '../models/history_model.dart';
import '../models/solution_model.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'chat_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = "";
  String _selectedFilter = 'Tất cả';

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
      bool matchesFilter = _selectedFilter == 'Tất cả';
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          _buildHeader(context, historyProvider.historyList.length),

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
          Text("Bạn chưa có lịch sử giải bài. Hãy bắt đầu giải bài tập ngay!", style: TextStyle(color: Colors.grey.shade500)),
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
            image: item.graphImage,
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

                        Row(
                          children: [
                            const Text(
                              "→ ",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal, // Cuộn ngang chống tràn viền
                                child: Math.tex(
                                  item.result.replaceAll(r'$', '').trim(),
                                  textStyle: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                  ),
                                  onErrorFallback: (err) => Text(
                                    item.result,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white38 : Colors.grey),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, thickness: 0.5),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
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
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Hủy", style: TextStyle(color: Colors.grey))
          ),
        ],
      ),
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