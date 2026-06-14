// lib/screens/admin/admin_users_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class AdminUsersScreen extends StatefulWidget {
  final String token;
  const AdminUsersScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _selectedFilter = 'Tất cả';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Sử dụng WidgetsBinding để gọi Provider sau khi frame đầu tiên được dựng xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchAllAdminData(widget.token);
    });
  }

  // Hàm định dạng ngày tháng hiển thị dạng DD/MM/YYYY từ chuỗi Backend trả về
  String _formatDate(dynamic createdAt) {
    if (createdAt == null) return '--/--/----';
    try {
      DateTime parsedDate = DateTime.parse(createdAt.toString());
      String day = parsedDate.day.toString().padLeft(2, '0');
      String month = parsedDate.month.toString().padLeft(2, '0');
      return '$day/$month/${parsedDate.year}';
    } catch (e) {
      return '--/--/----';
    }
  }

  // Hàm lấy 2 chữ cái đầu tiên của tên làm Avatar viết tắt giống thiết kế (ví dụ: Nguyễn Minh Tú -> NT)
  String _getInitials(String name) {
    if (name.isEmpty) return 'HS';
    List<String> words = name.trim().split(' ');
    if (words.length > 1) {
      return (words[0][0] + words[words.length - 1][0]).toUpperCase();
    }
    return words[0][0].toUpperCase();
  }

  // Hàm sinh màu nền ngẫu nhiên/cố định cho Avatar theo ID để giao diện sinh động như ảnh mẫu
  Color _getAvatarColor(int id) {
    List<Color> colors = [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF0D9488), // Teal
      const Color(0xFF059669), // Emerald
    ];
    return colors[id % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context);
    final List<dynamic> rawUsers = adminProv.users;

    // ==========================================
    // LOGIC TỰ ĐỘNG TÍNH TOÁN SỐ LIỆU THỰC TẾ
    // ==========================================
    int totalUsers = rawUsers.length;
    int activeUsers = rawUsers.where((u) => u['is_active'] == true).length;
    int lockedUsers = totalUsers - activeUsers;

    // Tiến hành lọc danh sách theo cả Ô tìm kiếm và Bộ lọc Chips (Tất cả / Hoạt động / Khóa)
    List<dynamic> filteredUsers = rawUsers.where((user) {
      String name = (user['name'] ?? '').toString().toLowerCase();
      String email = (user['email'] ?? '').toString().toLowerCase();
      bool matchesSearch = name.contains(_searchQuery) || email.contains(_searchQuery);

      if (!matchesSearch) return false;

      bool isActive = user['is_active'] ?? true;
      if (_selectedFilter == 'Đang hoạt động') {
        return isActive == true;
      } else if (_selectedFilter == 'Đã khóa') {
        return isActive == false;
      }
      return true; // Lựa chọn 'Tất cả'
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // ==========================================
          // 1. HEADER GRADIENT ĐỒNG BỘ 100% (ĐÃ BỎ TABS)
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
                      'Quản lý người dùng',
                      style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$totalUsers người dùng đã đăng ký',
                      style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // PHẦN THÂN CHỨA NỘI DUNG CUỘN
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==========================================
                  // 2. HÀNG 3 THẺ SỐ LIỆU THỐNG KÊ (ĐÃ BỎ PRO)
                  // ==========================================
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Tổng', totalUsers.toString(), Icons.people_alt_rounded, const Color(0xFF6366F1)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('Hoạt động', activeUsers.toString(), Icons.check_circle_outline_rounded, const Color(0xFF10B981)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('Đã khóa', lockedUsers.toString(), Icons.block_rounded, const Color(0xFFEF4444)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ==========================================
                  // 3. Ô TÌM KIẾM THEO TÊN / EMAIL CHUẨN UI
                  // ==========================================
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim().toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm tên hoặc email...',
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

                  // ==========================================
                  // 4. BỘ LỌC CHIPS ĐIỀU HƯỚNG TRẠNG THÁI (ĐÃ BỎ PRO)
                  // ==========================================
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Tất cả', 'Đang hoạt động', 'Đã khóa'].map((filter) {
                        bool isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (val) => setState(() => _selectedFilter = filter),
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
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 10),
                  // ==========================================
                  // 5. DANH SÁCH THẺ NGƯỜI DÙNG THỜI GIAN THỰC
                  // ==========================================
                  filteredUsers.isEmpty
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Text('Không tìm thấy học sinh nào phù hợp', style: GoogleFonts.dmSans(color: const Color(0xFF64748B))),
                    ),
                  )
                      : ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      bool isActive = user['is_active'] ?? true;

                      // Tìm chính xác vị trí index gốc của user này trong mảng dữ liệu tổng Provider
                      int originalIndex = rawUsers.indexWhere((u) => u['id'] == user['id']);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFFE2E8F0).withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 3)),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Khối hình tròn chứa chữ viết tắt Avatar giống hệt ảnh thiết kế
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _getAvatarColor(user['id'] ?? 0),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  _getInitials(user['name'] ?? ''),
                                  style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Khối thông tin chi tiết cá nhân học sinh
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user['name'] ?? 'Học sinh',
                                    style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user['email'] ?? '',
                                    style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF94A3B8)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  // Dòng chứa Badge trạng thái & Ngày tham gia
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isActive ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          isActive ? 'Hoạt động' : 'Đã khóa',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isActive ? const Color(0xFF059669) : const Color(0xFFEF4444),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '•  ${_formatDate(user['created_at'])}',
                                        style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            // Nút 3 chấm mở rộng ActionMenu Popup giống thiết kế
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              onSelected: (value) async {
                                if (value == 'toggle') {
                                  // Truyền đúng vị trí index gốc để Provider không cập nhật nhầm phần tử
                                  await adminProv.toggleUser(widget.token, user['id'], originalIndex);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'toggle',
                                  child: Row(
                                    children: [
                                      Icon(
                                        isActive ? Icons.block_rounded : Icons.check_circle_outline_rounded,
                                        color: isActive ? Colors.red.shade600 : Colors.green.shade600,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        isActive ? 'Khóa tài khoản' : 'Mở khóa tài khoản',
                                        style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
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

  // Widget bổ trợ dựng Thẻ số liệu thống kê ngang hàng
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFFE2E8F0).withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text(title, style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}