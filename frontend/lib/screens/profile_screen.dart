import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../core/theme/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedLanguage = 'Tiếng Việt';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadUser();
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'Tiếng Việt';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();

    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final user = auth.user;

        return Scaffold(
          backgroundColor: isDark ? AppColors.inputBackgroundDark : const Color(0xFFF8F9FA),
          body: (auth.isLoading && user == null)
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : RefreshIndicator(
            onRefresh: () => auth.loadUser(),
            color: AppColors.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Header đồng bộ màu
                      _buildPremiumHeader(
                          context,
                          user?.name ?? 'Người dùng',
                          user?.email ?? 'Chưa cập nhật email'
                      ),

                      Transform.translate(
                        offset: const Offset(0, -30),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Tài khoản'),
                              _buildPremiumCard(
                                isDark: isDark,
                                children: [
                                  _buildSettingsItem(
                                    icon: Icons.person_outline,
                                    iconColor: const Color(0xFF3B82F6),
                                    title: 'Họ và tên',
                                    subtitle: user?.name,
                                    onTap: () => _showCustomModal(context, auth, 'edit_name'),
                                  ),
                                  _buildDivider(isDark),
                                  _buildSettingsItem(
                                    icon: Icons.email_outlined,
                                    iconColor: const Color(0xFFF59E0B),
                                    title: 'Địa chỉ Email',
                                    subtitle: user?.email,
                                  ),
                                  _buildDivider(isDark),
                                  _buildSettingsItem(
                                    icon: Icons.lock_outline,
                                    iconColor: const Color(0xFFEF4444),
                                    title: 'Đổi mật khẩu',
                                    onTap: () => _showCustomModal(context, auth, 'change_password'),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 25),
                              _buildSectionTitle('Tùy chỉnh hệ thống'),
                              _buildPremiumCard(
                                isDark: isDark,
                                children: [
                                  _buildSettingsItem(
                                    icon: Icons.language_rounded,
                                    iconColor: const Color(0xFF10B981),
                                    title: 'Ngôn ngữ',
                                    subtitle: _selectedLanguage,
                                    onTap: () => _showLanguageModal(context),
                                  ),
                                  _buildDivider(isDark),
                                  _buildSettingsSwitch(
                                    icon: Icons.dark_mode_outlined,
                                    iconColor: const Color(0xFF8B5CF6),
                                    title: 'Giao diện tối',
                                    value: themeProvider.isDarkMode,
                                    onChanged: (v) => themeProvider.toggleTheme(v),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 35),
                              // Nút đăng xuất thích ứng Dark Mode
                              _buildLogoutButton(context, auth, isDark),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= 1. HEADER =================
  Widget _buildPremiumHeader(BuildContext context, String name, String email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 70, bottom: 60, left: 24, right: 24),
      decoration: const BoxDecoration(
        color: AppColors.primary, // Cố định màu chuẩn của App
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 38,
              backgroundColor: Colors.white,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'Q',
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    email,
                    style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= 2. COMPONENTS (ĐÃ FIX OVERFLOW) =================
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildPremiumCard({required bool isDark, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    VoidCallback? onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (subtitle != null)
                    Flexible(
                      child: Text(
                        subtitle,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  if (onTap != null) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSwitch({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required Function(bool) onChanged
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
          Switch.adaptive(value: value, onChanged: onChanged, activeColor: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(height: 1, indent: 70, endIndent: 20, color: isDark ? Colors.white10 : Colors.grey.shade100);
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider auth, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: isDark ? const Color(0xFFEF4444).withOpacity(0.15) : const Color(0xFFFEF2F2),
          foregroundColor: const Color(0xFFEF4444),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: () => _showCustomModal(context, auth, 'logout'),
        child: const Text('Đăng xuất'),
      ),
    );
  }

  // ================= 3. MODALS =================
  void _showCustomModal(BuildContext context, AuthProvider auth, String type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameCtrl = TextEditingController(text: auth.user?.name);
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController(); // Thêm ô xác nhận mật khẩu

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: type == 'logout' ? const Color(0xFFFEF2F2) : AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  type == 'edit_name' ? Icons.person_outline : type == 'change_password' ? Icons.lock_outline : Icons.logout_rounded,
                  color: type == 'logout' ? const Color(0xFFEF4444) : AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                type == 'edit_name' ? 'Chỉnh sửa tên' : type == 'change_password' ? 'Đổi mật khẩu' : 'Xác nhận đăng xuất',
                style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                type == 'edit_name' ? 'Tên này sẽ hiển thị trên trang cá nhân của bạn.'
                    : type == 'change_password' ? 'Mật khẩu mới phải có ít nhất 6 ký tự.'
                    : 'Bạn sẽ cần đăng nhập lại để tiếp tục sử dụng.',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // UI: Các trường nhập liệu
              if (type == 'edit_name')
                _buildModernInput(ctx, nameCtrl, 'Họ và tên', Icons.badge_outlined, false),
              if (type == 'change_password') ...[
                _buildModernInput(ctx, oldPassCtrl, 'Mật khẩu hiện tại', Icons.password_rounded, true),
                const SizedBox(height: 12),
                _buildModernInput(ctx, newPassCtrl, 'Mật khẩu mới', Icons.lock_reset_rounded, true),
                const SizedBox(height: 12),
                _buildModernInput(ctx, confirmPassCtrl, 'Xác nhận mật khẩu mới', Icons.lock_outline, true),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: type == 'logout' ? const Color(0xFFEF4444) : AppColors.primary,
                    // CHUYỂN STYLE VÀO ĐÂY:
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    if (type == 'edit_name') {
                      if (nameCtrl.text.trim().isEmpty) {
                        _showErrorToast(context, 'Tên không được để trống!');
                        return;
                      }
                      await auth.updateProfile(name: nameCtrl.text.trim(), email: '');
                      if (mounted) Navigator.pop(ctx);
                    }
                    else if (type == 'change_password') {
                      final oldPass = oldPassCtrl.text;
                      final newPass = newPassCtrl.text;
                      final confirmPass = confirmPassCtrl.text;

                      if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                        _showErrorToast(context, 'Vui lòng điền đầy đủ các trường!');
                        return;
                      }
                      if (newPass.length < 6) {
                        _showErrorToast(context, 'Mật khẩu mới phải có ít nhất 6 ký tự!');
                        return;
                      }
                      if (oldPass == newPass) {
                        _showErrorToast(context, 'Mật khẩu mới không được giống mật khẩu cũ!');
                        return;
                      }
                      if (newPass != confirmPass) {
                        _showErrorToast(context, 'Mật khẩu xác nhận không khớp!');
                        return;
                      }

                      final success = await auth.changePassword(oldPassword: oldPass, newPassword: newPass);
                      if (success && mounted) {
                        Navigator.pop(ctx);
                        _showSuccessToast(context, 'Đổi mật khẩu thành công!');
                      }
                    }
                    else if (type == 'logout') {
                      await auth.logout();
                      if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
                    }
                  },
                  // THẺ TEXT XÓA BỎ STYLE BÊN TRONG:
                  child: Text(type == 'logout' ? 'Đăng xuất ngay' : 'Lưu thay đổi'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton(
                  style: TextButton.styleFrom(
                    // CHUYỂN STYLE VÀO ĐÂY:
                      foregroundColor: Colors.grey,
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  // THẺ TEXT XÓA BỎ STYLE BÊN TRONG:
                  child: const Text('Hủy bỏ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(message))
            ]
        ),
        backgroundColor: const Color(0xFFEF4444), // Màu đỏ cảnh báo
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3), // Tự động ẩn sau 3 giây
      ),
    );
  }

  void _showLanguageModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final languages = [{'name': 'Tiếng Việt', 'flag': '🇻🇳'}, {'name': 'English', 'flag': '🇬🇧'}, {'name': '日本語', 'flag': '🇯🇵'}];

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Chọn ngôn ngữ', style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ...languages.map((lang) {
                bool isSelected = _selectedLanguage == lang['name'];
                return InkWell(
                  onTap: () async {
                    setState(() => _selectedLanguage = lang['name']!);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('language', lang['name']!);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
                    child: Row(
                      children: [
                        Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 16),
                        Expanded(child: Text(lang['name']!, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
                        if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernInput(BuildContext context, TextEditingController controller, String hint, IconData icon, bool isPassword) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
        prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 22),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF3F4F6),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  void _showSuccessToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [const Icon(Icons.check_circle, color: Colors.white), const SizedBox(width: 10), Text(message)]),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }
}