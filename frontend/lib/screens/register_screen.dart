// lib/screens/register_screen.dart
import 'package:algebra_chatbot/screens/home_screen.dart';
import 'package:algebra_chatbot/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';
import 'chat_screen.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  bool _loading        = false;
  bool _agree          = false;

  String? _nameError;
  String? _emailError;
  String? _passError;
  String? _confirmError;

  late AnimationController _animCtrl;
  late Animation<double>  _fadeAnim;
  late Animation<Offset>  _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim  = Tween<double>(begin: 0, end: 1).animate(_animCtrl);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    _confirmCtrl.dispose(); _animCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _nameError    = _nameCtrl.text.trim().isEmpty ? 'Vui lòng nhập tên' : null;
      _emailError   = _emailCtrl.text.trim().isEmpty ? 'Vui lòng nhập email' : null;
      _passError    = _passCtrl.text.length < 8 ? 'Mật khẩu tối thiểu 8 ký tự' : null;
      _confirmError = _confirmCtrl.text != _passCtrl.text ? 'Mật khẩu không khớp' : null;
    });
    return _nameError == null && _emailError == null && _passError == null && _confirmError == null;
  }

  Future<void> _register() async {
    if (!_validate()) return;
    setState(() => _loading = true);
    try {
      final token = await AuthService.register(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red.shade600));
    }
  }

  Future<void> _registerWithGoogle() async {
    setState(() => _loading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(serverClientId: '386538483858-t13b687hnu9hqee8r375vt7cb4q75ajl.apps.googleusercontent.com');
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) { setState(() => _loading = false); return; }
      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;
      if (idToken == null) throw 'Không lấy được Token từ Google';
      final accessToken = await AuthService.loginWithGoogle(idToken);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', accessToken);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red.shade600));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Tự đổi màu nền
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Đăng ký', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RegisterBanner(),
                  const SizedBox(height: 28),
                  Text(
                    'Tạo tài khoản mới',
                    style: GoogleFonts.dmSans(
                      fontSize: 24, fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface, letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tham gia cùng hàng ngàn học sinh học toán cùng AI',
                    style: GoogleFonts.dmSans(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 28),

                  _AuthField(label: 'Tên hiển thị', hint: 'Nguyễn Văn A', controller: _nameCtrl, icon: Icons.person_outline_rounded, errorText: _nameError),
                  const SizedBox(height: 16),
                  _AuthField(label: 'Email', hint: 'your@email.com', controller: _emailCtrl, icon: Icons.email_outlined, type: TextInputType.emailAddress, errorText: _emailError),
                  const SizedBox(height: 16),
                  _PasswordField(label: 'Mật khẩu', hint: 'Tối thiểu 8 ký tự', controller: _passCtrl, obscure: _obscurePass, onToggle: () => setState(() => _obscurePass = !_obscurePass), errorText: _passError),
                  const SizedBox(height: 16),
                  _PasswordField(label: 'Xác nhận mật khẩu', hint: 'Nhập lại mật khẩu', controller: _confirmCtrl, obscure: _obscureConfirm, onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm), errorText: _confirmError),

                  const SizedBox(height: 12),
                  _PasswordStrength(password: _passCtrl.text),
                  const SizedBox(height: 20),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24, height: 24,
                        child: Checkbox(
                          value: _agree,
                          onChanged: (v) => setState(() => _agree = v ?? false),
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.dmSans(fontSize: 13, color: colorScheme.onSurface.withOpacity(0.7)),
                            children: [
                              const TextSpan(text: 'Tôi đồng ý với '),
                              TextSpan(text: 'Điều khoản dịch vụ', style: GoogleFonts.dmSans(color: AppColors.primary, fontWeight: FontWeight.w600)),
                              const TextSpan(text: ' và '),
                              TextSpan(text: 'Chính sách bảo mật', style: GoogleFonts.dmSans(color: AppColors.primary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: (_loading || !_agree) ? null : _register,
                      child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : const Text('Tạo tài khoản'),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const _Divider(),
                  const SizedBox(height: 24),
                  _SocialLoginButton(icon: '🌐', label: 'Đăng ký với Google', onTap: _registerWithGoogle),

                  const SizedBox(height: 32),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Đã có tài khoản? ', style: GoogleFonts.dmSans(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Đăng nhập'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Widgets phụ trợ (Đã đồng bộ Theme) ───

class _RegisterBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🎓 Học toán thông minh', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.primaryDark)),
                const SizedBox(height: 4),
                Text('AI giải thích từng bước,\ndễ hiểu & nhanh chóng', style: GoogleFonts.dmSans(fontSize: 12, color: isDark ? Colors.white70 : AppColors.primary, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
            child: const Center(child: Text('Q', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold))),
          ),
        ],
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType type;
  final String? errorText;

  const _AuthField({required this.label, required this.hint, required this.controller, required this.icon, this.type = TextInputType.text, this.errorText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 8),
        TextField(
          controller: controller, keyboardType: type,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, size: 20), errorText: errorText),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final String? errorText;

  const _PasswordField({required this.label, required this.hint, required this.controller, required this.obscure, required this.onToggle, this.errorText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 8),
        TextField(
          controller: controller, obscureText: obscure,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(hintText: hint, prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20), onPressed: onToggle),
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface.withOpacity(0.3);
    return Row(children: [
      Expanded(child: Divider(color: color)),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('hoặc', style: GoogleFonts.dmSans(fontSize: 13, color: color))),
      Expanded(child: Divider(color: color)),
    ]);
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String icon, label;
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
        backgroundColor: theme.colorScheme.surface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }
}

// Giữ nguyên logic PasswordStrength cũ nhưng đổi màu divider một chút
class _PasswordStrength extends StatelessWidget {
  final String password;
  const _PasswordStrength({required this.password});
  int get _strength {
    if (password.isEmpty) return 0;
    int s = 0; if (password.length >= 8) s++; if (password.contains(RegExp(r'[A-Z]'))) s++;
    if (password.contains(RegExp(r'[0-9]'))) s++; if (password.contains(RegExp(r'[!@#\$%^&*]'))) s++;
    return s;
  }
  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    final color = [AppColors.divider, AppColors.error, AppColors.warning, AppColors.success, AppColors.success][_strength];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: List.generate(4, (i) => Expanded(child: Container(height: 4, margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
        decoration: BoxDecoration(color: i < _strength ? color : Theme.of(context).dividerTheme.color, borderRadius: BorderRadius.circular(2)),
      )))),
      const SizedBox(height: 6),
      Text('Độ mạnh: ${['', 'Yếu', 'Trung bình', 'Mạnh', 'Rất mạnh'][_strength]}', style: GoogleFonts.dmSans(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    ]);
  }
}