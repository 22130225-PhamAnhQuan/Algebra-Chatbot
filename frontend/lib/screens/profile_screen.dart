// lib/screens/profile_screen.dart
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

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
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
    final themeProvider = context.watch<ThemeProvider>();

    // Sử dụng Consumer để lắng nghe AuthProvider một cách trực tiếp và mạnh mẽ nhất
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final user = auth.user;

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: (auth.isLoading && user == null)
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : RefreshIndicator(
            onRefresh: () => auth.loadUser(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildTopHeader(
                      context,
                      user?.name ?? (auth.isLoading ? 'Đang tải...' : 'Chưa có tên'),
                      user?.email ?? (auth.isLoading ? 'Đang tải...' : 'Chưa có email')
                  ),

                  Transform.translate(
                    offset: const Offset(0, -25),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                        boxShadow: [
                          if (!themeProvider.isDarkMode)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -5),
                            ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel(context, 'TÀI KHOẢN'),
                          _buildSettingsGroup(context, [
                            _buildTile(
                                context,
                                Icons.person_outline,
                                'Tên',
                                value: user?.name,
                                onTap: () => _showEditDialog(context, auth)
                            ),
                            _buildTile(
                                context,
                                Icons.email_outlined,
                                'Email',
                                value: user?.email
                            ),
                            _buildTile(
                                context,
                                Icons.lock_outline,
                                'Đổi mật khẩu',
                                onTap: () => _showChangePasswordDialog(context, auth)
                            ),
                          ]),

                          const SizedBox(height: 24),
                          _buildSectionLabel(context, 'TÙY CHỈNH'),
                          _buildSettingsGroup(context, [
                            _buildTile(
                                context,
                                Icons.language_rounded,
                                'Ngôn ngữ',
                                value: _selectedLanguage,
                                onTap: () => _showLanguageDialog(context)
                            ),
                            _buildSwitchTile(
                                context,
                                Icons.dark_mode_outlined,
                                'Chế độ tối',
                                themeProvider.isDarkMode,
                                    (v) => themeProvider.toggleTheme(v)
                            ),
                          ]),

                          const SizedBox(height: 32),
                          _buildLogoutButton(context, auth),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopHeader(BuildContext context, String name, String email) {
    return Container(
      width: double.infinity,
      // Không để height cứng nữa, để nó tự giãn hoặc dùng padding lớn ở dưới
      padding: const EdgeInsets.only(bottom: 50),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // 1. Vòng tròn mờ (Decorative Circle) - Cho opacity thấp hơn để nhìn tinh tế
          Positioned(
            right: -30,
            top: -10,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // 3. Nội dung chính (Tiêu đề + Avatar + Info)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hồ sơ',
                  style: GoogleFonts.dmSans(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    // Avatar vuông bo góc (Squircle)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 85,
                          height: 85,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        // Chấm xanh trạng thái
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary, width: 3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    // Thông tin User
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- CÁC HÀM DIALOG VÀ COMPONENT GIỮ NGUYÊN ---
  void _showEditDialog(BuildContext context, AuthProvider auth) {
    final nameCtrl = TextEditingController(text: auth.user?.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Chỉnh sửa tên', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
          decoration: const InputDecoration(hintText: 'Nhập tên mới'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final success = await auth.updateProfile(name: nameCtrl.text.trim(), email: '');
              if (success && mounted) Navigator.pop(ctx);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, AuthProvider auth) {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Đổi mật khẩu', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldPassCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'Mật khẩu cũ')),
            const SizedBox(height: 10),
            TextField(controller: newPassCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'Mật khẩu mới')),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final success = await auth.changePassword(oldPassword: oldPassCtrl.text, newPassword: newPassCtrl.text);
              if (success && mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã đổi mật khẩu thành công!')));
              }
            },
            child: const Text('Cập nhật'),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final languages = ['Tiếng Việt', 'English', '日本語'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Chọn ngôn ngữ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) => RadioListTile<String>(
            title: Text(lang, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            value: lang, groupValue: _selectedLanguage, activeColor: AppColors.primary,
            onChanged: (v) async {
              if (v != null) {
                setState(() => _selectedLanguage = v);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('language', v);
                Navigator.pop(ctx);
              }
            },
          )).toList(),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn có chắc muốn thoát tài khoản này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
              onPressed: () async {
                await auth.logout();
                if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
              },
              child: const Text('Đăng xuất', style: TextStyle(color: AppColors.error))
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(label, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1)),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
      ),
      child: Column(children: tiles),
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String label, {String? value, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
      trailing: value != null
          ? Text(value, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13,))
          : Icon(Icons.chevron_right, color: Theme.of(context).hintColor, size: 18),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(BuildContext context, IconData icon, String label, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
      trailing: Switch.adaptive(value: value, onChanged: onChanged, activeColor: AppColors.primary),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider auth) {
    return OutlinedButton.icon(
      onPressed: () => _confirmLogout(context, auth),
      icon: const Icon(Icons.logout_rounded, size: 18),
      label: const Text('Đăng xuất'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error, minimumSize: const Size(double.infinity, 54),
        side: const BorderSide(color: AppColors.error),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}