// lib/screens/admin/admin_histories_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class AdminHistoriesScreen extends StatefulWidget {
  final String token;
  const AdminHistoriesScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<AdminHistoriesScreen> createState() => _AdminHistoriesScreenState();
}

class _AdminHistoriesScreenState extends State<AdminHistoriesScreen> {
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  String _formatDateTime(dynamic createdAt) {
    if (createdAt == null) return 'Vừa xong';
    try {
      DateTime parsedDate = DateTime.parse(createdAt.toString());
      String day = parsedDate.day.toString().padLeft(2, '0');
      String month = parsedDate.month.toString().padLeft(2, '0');
      String hour = parsedDate.hour.toString().padLeft(2, '0');
      String minute = parsedDate.minute.toString().padLeft(2, '0');
      return '$day/$month/${parsedDate.year} $hour:$minute';
    } catch (e) {
      return 'Vừa xong';
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context);
    final List<dynamic> rawHistories = adminProv.histories;

    final overview = adminProv.stats?['overview'] ?? {};
    final aiPerf = adminProv.stats?['ai_engine_performance'] ?? {};

    List<dynamic> filteredHistories = rawHistories.where((h) {
      final userObj = h['user'] != null ? Map<String, dynamic>.from(h['user']) : null;
      final probObj = h['problem'] != null ? Map<String, dynamic>.from(h['problem']) : null;

      String studentName = (userObj?['name'] ?? '').toString().toLowerCase();
      String problemContent = (probObj?['content'] ?? '').toString().toLowerCase();

      return studentName.contains(_searchQuery) || problemContent.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
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
                      'Quản lý lịch sử',
                      style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${rawHistories.length} lượt giải toán hệ thống',
                      style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Tổng lượt giải', '${overview['total_problems_submitted'] ?? rawHistories.length}', Icons.bar_chart_rounded, const Color(0xFF6366F1)),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim().toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm người dùng hoặc bài giải.....',
                      hintStyle: GoogleFonts.dmSans(color: const Color(0xFF94A3B8), fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  filteredHistories.isEmpty
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Text('Không tìm thấy lịch sử giải bài nào', style: GoogleFonts.dmSans(color: const Color(0xFF64748B))),
                    ),
                  )
                      : ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredHistories.length,
                    itemBuilder: (context, index) {
                      final history = filteredHistories[index];

                      // Bóc tách an toàn cấu trúc Object lồng nhau từ FastAPI
                      final Map<String, dynamic>? userObj = history['user'] != null ? Map<String, dynamic>.from(history['user']) : null;
                      final Map<String, dynamic>? probObj = history['problem'] != null ? Map<String, dynamic>.from(history['problem']) : null;
                      final Map<String, dynamic>? solObj = history['solution'] != null ? Map<String, dynamic>.from(history['solution']) : null;

                      String equation = probObj?['content'] ?? 'Nội dung trống';
                      String resultText = solObj?['result'] ?? 'Chưa có đáp án';
                      String studentName = userObj?['name'] ?? 'Ẩn danh';
                      String problemType = solObj?['problem_type'] ?? 'Đại số';
                      String solverModel = solObj?['model'] ?? 'ai';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFFE2E8F0).withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hàng chứa: Đề bài gốc + Nút Xóa
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    equation,
                                    style: GoogleFonts.firaCode(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    // Xử lý chức năng xóa lịch sử giải nếu cần
                                  },
                                  icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 20),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Dòng hiển thị kết quả rút gọn của bài toán
                            Text(
                              '→ $resultText',
                              style: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xFF4F46E5), fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 14),

                            // Hàng chứa: Badge loại bài toán (Bậc 2, Hệ PT...) + Tên học sinh
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF7ED), // Màu nền cam nhạt dứt điểm lỗi slate/emerald
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    problemType,
                                    style: GoogleFonts.dmSans(color: const Color(0xFFEA580C), fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  studentName,
                                  style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Divider(color: const Color(0xFFF1F5F9), thickness: 1.2),
                            ),

                            // Hàng đáy chứa: Thời gian giải bài toán + Badge Model sử dụng
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF94A3B8)),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatDateTime(history['created_at']),
                                      style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F3FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    solverModel == 'ai' ? 'Gemini Engine' : 'SymPy Core',
                                    style: GoogleFonts.firaCode(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF6D28D9)),
                                  ),
                                )
                              ],
                            )
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

  // Widget bổ trợ xây dựng Thẻ số liệu thống kê 3 cột cân đối đầu trang
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFFE2E8F0).withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}