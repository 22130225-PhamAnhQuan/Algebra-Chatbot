// lib/screens/admin/admin_logs_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class AdminAILogsScreen extends StatefulWidget {
  final String token;
  const AdminAILogsScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<AdminAILogsScreen> createState() => _AdminAILogsScreenState();
}

class _AdminAILogsScreenState extends State<AdminAILogsScreen> {
  String _selectedFilter = 'Tất cả';

  // Hàm chuyển đổi chuỗi ISO DateTime từ Backend thành giờ hiển thị (HH:mm:ss)
  String _formatTime(dynamic createdAt) {
    if (createdAt == null) return '00:00:00';
    try {
      DateTime parsedDate = DateTime.parse(createdAt.toString());
      // Thêm số 0 phía trước nếu giờ/phút/giây nhỏ hơn 10
      String hour = parsedDate.hour.toString().padLeft(2, '0');
      String minute = parsedDate.minute.toString().padLeft(2, '0');
      String second = parsedDate.second.toString().padLeft(2, '0');
      return '$hour:$minute:$second';
    } catch (e) {
      return '00:00:00';
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context);
    final List<dynamic> rawLogs = adminProv.aiLogs;

    // ==========================================
    // KHỚP CHUẨN LOGIC TÍNH TOÁN TỪ BACKEND ĐỐI CHIẾU
    // ==========================================
    int totalCalls = rawLogs.length;
    // Kiểm tra trạng thái thành công (FastAPI lưu chuỗi 'success' hoặc mã 200)
    int successCount = rawLogs.where((l) => l['status'] == 'success' || l['status'] == 200 || l['status'] == '200' || l['status'] == null).length;
    double successRate = totalCalls > 0 ? (successCount / totalCalls) * 100 : 100.0;

    int totalLatency = 0;
    int totalTokens = 0;
    int geminiProCount = 0;

    for (var log in rawLogs) {
      totalLatency += (log['latency_ms'] as num? ?? 0).toInt();
      totalTokens += (log['tokens_used'] as num? ?? 0).toInt();

      // So khớp với trường log.model từ FastAPI
      String modelType = (log['model'] ?? '').toString().toLowerCase();
      if (modelType.contains('pro')) {
        geminiProCount++;
      }
    }
    int avgLatency = totalCalls > 0 ? (totalLatency ~/ totalCalls) : 0;

    // Lọc danh sách theo bộ chọn ChoiceChip công khai
    List<dynamic> filteredLogs = rawLogs.where((log) {
      String statusStr = (log['status'] ?? '').toString().toLowerCase();
      if (_selectedFilter == 'Thành công') {
        return statusStr == 'success' || statusStr == '200';
      } else if (_selectedFilter == 'Lỗi') {
        return statusStr == 'error' || statusStr == '400' || statusStr == '500';
      } else if (_selectedFilter == 'Timeout') {
        return statusStr.contains('timeout');
      }
      return true; // Chọn 'Tất cả'
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // 1. HEADER GRADIENT TÍNH TẾ (KHÔNG CÓ TABS)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 56, left: 20, right: 20, bottom: 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quản lý AI Logs', style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text('AI Engine', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),

          // DANH SÁCH CUỘN CHỨA NỘI DUNG REAL-TIME
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. LƯỚI 4 THẺ SỐ LIỆU THỰC TẾ
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.35,
                    children: [
                      _buildStatCard('Tổng API calls', totalCalls.toString(), Icons.developer_board_rounded, const Color(0xFF6366F1)),
                      _buildStatCard('Tỉ lệ thành công', '${successRate.toStringAsFixed(0)}%', Icons.trending_up_rounded, const Color(0xFF10B981)),
                      _buildStatCard('Latency TB', '${avgLatency}ms', Icons.bolt_rounded, const Color(0xFFF59E0B)),
                      _buildStatCard('Tổng tokens', totalTokens > 1000 ? '${(totalTokens / 1000).toStringAsFixed(1)}K' : totalTokens.toString(), Icons.toll_rounded, const Color(0xFF0EA5E9)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 3. THẺ TIẾN TRÌNH PHÂN PHỐI MODEL
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: const Color(0xFFE2E8F0).withOpacity(0.7), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Model sử dụng', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                        const SizedBox(height: 16),
                        _buildModelProgress('Phi3-mini', geminiProCount, totalCalls)
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. BỘ LỌC CHIPS CHÂN THỰC
                  Text('Nhật ký chi tiết', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Tất cả', 'Thành công', 'Lỗi', 'Timeout'].map((filter) {
                        bool isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (val) => setState(() => _selectedFilter = filter),
                            selectedColor: const Color(0xFF4F46E5),
                            backgroundColor: Colors.white,
                            labelStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? Colors.white : const Color(0xFF64748B)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            side: BorderSide(color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0)),
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  filteredLogs.isEmpty
                      ? Center(child: Padding(padding: const EdgeInsets.only(top: 10), child: Text('Không tìm thấy bản ghi log nào thỏa mãn', style: GoogleFonts.dmSans(color: const Color(0xFF64748B)))))
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];

                      String equation = log['input'] ?? 'Trống';
                      String userId = 'Học sinh ID: ${log['user_id'] ?? 'Ẩn danh'}';
                      String timeString = _formatTime(log['created_at']);
                      int latencyMs = (log['latency_ms'] as num? ?? 0).toInt();

                      String statusStr = (log['status'] ?? '').toString().toLowerCase();
                      bool isError = statusStr == 'error' || statusStr == '400' || statusStr == '500';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: const Color(0xFFE2E8F0).withOpacity(0.5), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
                              color: isError ? Colors.red.shade500 : const Color(0xFF10B981),
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(equation, style: GoogleFonts.firaCode(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text(userId, style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(timeString, style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF94A3B8))),
                                const SizedBox(height: 4),
                                Text('$latencyMs ms', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold, color: isError ? Colors.red.shade600 : const Color(0xFF10B981))),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: const Color(0xFFE2E8F0).withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 3))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              const SizedBox(height: 2),
              Text(title, style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildModelProgress(String modelName, int count, int total) {
    double factor = total > 0 ? (count / total) : 0.0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(modelName, style: GoogleFonts.firaCode(fontSize: 13, color: const Color(0xFF334155), fontWeight: FontWeight.w500)),
            Text('$count calls', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF4F46E5))),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: factor,
            minHeight: 8,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          ),
        )
      ],
    );
  }
}