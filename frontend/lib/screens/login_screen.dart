// lib/screens/login_screen.dart
import 'package:algebra_chatbot/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../services/api_service.dart';
import 'forgotpw_screen.dart';
import 'profile_screen.dart';
import 'register_screen.dart';
import 'home_screen.dart'; // Đảm bảo import HomeScreen nếu bạn muốn vào đó

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn),
    );
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    try {
      if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
        throw 'Vui lòng nhập đầy đủ Email và Mật khẩu';
      }

      setState(() => _loading = true);

      final token = await ApiService.login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      if (mounted) {
        await context.read<AuthProvider>().loadUser();
      }

      if (!mounted) return;
      setState(() => _loading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );

    } catch (e) {
      setState(() => _loading = false);

      String rawError = e.toString();
      String friendlyMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại';

      if (rawError.contains('value is not a valid email address')) {
        friendlyMessage = 'Email không đúng định dạng (thiếu dấu chấm hoặc sai ký tự)';
      } else if (rawError.contains('not_found') || rawError.contains('401')) {
        friendlyMessage = 'Email hoặc mật khẩu không chính xác';
      } else if (rawError.contains('Connection refused')) {
        friendlyMessage = 'Không thể kết nối đến máy chủ';
      } else {
        // Nếu không khớp các lỗi trên thì mới hiện thông báo gốc (đã lọc bớt rác)
        friendlyMessage = rawError.replaceAll('Exception: ', '');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            friendlyMessage, // Hiện câu thông báo đã "dịch"
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, color: Colors.white),
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _handleGoogleAuth() async {
    setState(() => _loading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: '386538483858-t13b687hnu9hqee8r375vt7cb4q75ajl.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        setState(() => _loading = false);
        return;
      }
      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;
      if (idToken == null) throw 'Không lấy được Token từ Google';

      final accessToken = await ApiService.loginWithGoogle(idToken);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', accessToken);

      if (mounted) {
        await context.read<AuthProvider>().loadUser();
      }

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    // 💡 LẤY THÔNG TIN THEME TẠI ĐÂY ĐỂ DÙNG MÀU ĐỘNG
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Tự động đổi Sáng/Tối
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(isDark ? 0.03 : 0.06),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 56),
                      Center(child: AppLogo(size: 72)),
                      const SizedBox(height: 40),
                      Text(
                        'Chào mừng trở lại! 👋',
                        style: GoogleFonts.dmSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface, // Tự trắng khi tối
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Đăng nhập để tiếp tục giải toán',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          color: theme.colorScheme.onSurface.withOpacity(0.6), // Tự đổi màu xám/trắng
                        ),
                      ),
                      const SizedBox(height: 36),
                      _FieldLabel(label: 'Email'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: const InputDecoration(
                          hintText: 'youremail@email.com',
                          prefixIcon: Icon(Icons.email_outlined, size: 20),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _FieldLabel(label: 'Mật khẩu'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                          child: const Text('Quên mật khẩu?'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          child: _loading
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                              : const Text('Đăng nhập'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _Divider(),
                      const SizedBox(height: 24),
                      _SocialLoginButton(
                        icon: '🌐',
                        label: 'Tiếp tục với Google',
                        onTap: _handleGoogleAuth,
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Chưa có tài khoản? ',
                              style: GoogleFonts.dmSans(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 14),
                            ),
                            TextButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                              child: const Text('Đăng ký ngay'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 💡 CÁC WIDGET CON ĐÃ ĐƯỢC ĐỒNG BỘ MÀU THEME
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Divider(color: theme.dividerTheme.color)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('hoặc', style: GoogleFonts.dmSans(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.5))),
        ),
        Expanded(child: Divider(color: theme.dividerTheme.color)),
      ],
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _SocialLoginButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(color: theme.dividerTheme.color ?? AppColors.divider, width: 1.5),
        backgroundColor: theme.colorScheme.surface, // Tự xám đen khi tối
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface, // Chữ tự trắng
            ),
          ),
        ],
      ),
    );
  }
}