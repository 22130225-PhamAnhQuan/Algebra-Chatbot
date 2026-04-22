// lib/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  // ... (Giữ nguyên các controller và biến logic)
  final _emailCtrl = TextEditingController();
  final _otpCtrls = List.generate(6, (_) => TextEditingController());
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  int _step = 0;
  bool _loading = false;
  bool _obscureNew = true;
  bool _obscureConf = true;
  int _resendTimer = 300;
  bool _canResend = false;
  String? _otpError;

  late AnimationController _animCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..forward();
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn));
  }

  // ... (Giữ nguyên các hàm dispose, _nextStep, _startTimer)
  @override
  void dispose() {
    _emailCtrl.dispose();
    for (final c in _otpCtrls) c.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _nextStep() async {
    try {
      setState(() => _otpError = null);
      if (_step == 0) {
        if (_emailCtrl.text.trim().isEmpty) throw 'Vui lòng nhập email của bạn';
        if (!_emailCtrl.text.contains('@')) throw 'Email không hợp lệ';
      }
      if (_step == 1) {
        final otp = _otpCtrls.map((e) => e.text).join();
        if (otp.length != 6) throw 'Vui lòng nhập đủ 6 số OTP';
      }
      if (_step == 2) {
        if (_newPassCtrl.text.length < 8) throw 'Mật khẩu tối thiểu 8 ký tự';
        if (_newPassCtrl.text != _confirmPassCtrl.text) throw 'Mật khẩu xác nhận không khớp';
      }

      setState(() => _loading = true);

      if (_step == 0) await ApiService.forgotPassword(_emailCtrl.text.trim());
      if (_step == 1) {
        final otp = _otpCtrls.map((e) => e.text).join();
        await ApiService.verifyOtp(email: _emailCtrl.text.trim(), otp: otp);
      }
      if (_step == 2) {
        final otp = _otpCtrls.map((e) => e.text).join();
        await ApiService.resetPassword(email: _emailCtrl.text.trim(), otp: otp, newPassword: _newPassCtrl.text);
      }

      if (!mounted) return;
      setState(() { _loading = false; _step++; });
      _animCtrl..reset()..forward();
      if (_step == 1) _startTimer();
    } catch (e) {
      setState(() => _loading = false);
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      if (_step == 1) {
        setState(() {
          _otpError = errorMessage;
          for (var ctrl in _otpCtrls) ctrl.clear();
        });
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.red.shade600));
    }
  }

  void _startTimer() async {
    setState(() { _resendTimer = 300; _canResend = false; });
    while (_resendTimer > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _resendTimer--);
    }
    setState(() => _canResend = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Tự đổi nền
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: colorScheme.onSurface),
          onPressed: () {
            if (_step > 0 && _step < 3) {
              setState(() => _step--);
              _animCtrl..reset()..forward();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(_stepTitle(), style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_step < 3) ...[
                  _StepProgress(current: _step),
                  const SizedBox(height: 32),
                ],
                if (_step == 0) _buildEmailStep(context),
                if (_step == 1) _buildOtpStep(context),
                if (_step == 2) _buildNewPasswordStep(context),
                if (_step == 3) _buildSuccessStep(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _stepTitle() => ['Quên mật khẩu', 'Xác minh OTP', 'Mật khẩu mới', 'Hoàn tất'][_step];

  // ── STEP 0: Nhập email ───────────────────────────────────────────────────────
  Widget _buildEmailStep(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepIcon(icon: Icons.email_outlined),
        const SizedBox(height: 24),
        Text('Nhập email của bạn', style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w800, color: colorScheme.onSurface, letterSpacing: -0.5)),
        const SizedBox(height: 8),
        Text('Chúng tôi sẽ gửi mã xác minh đến email của bạn.', style: GoogleFonts.dmSans(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.6))),
        const SizedBox(height: 32),
        const _FieldLabel('Email'),
        const SizedBox(height: 8),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: const InputDecoration(hintText: 'your@email.com', prefixIcon: Icon(Icons.email_outlined, size: 20)),
        ),
        const SizedBox(height: 32),
        ElevatedButton(onPressed: _loading ? null : _nextStep, child: _loading ? const _LoadingIndicator() : const Text('Gửi mã xác minh')),
      ],
    );
  }

  // ── STEP 1: Nhập OTP ─────────────────────────────────────────────────────────
  Widget _buildOtpStep(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepIcon(icon: Icons.sms_outlined),
        const SizedBox(height: 24),
        Text('Nhập mã xác minh', style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w800, color: colorScheme.onSurface)),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: GoogleFonts.dmSans(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.6), height: 1.5),
            children: [
              const TextSpan(text: 'Mã OTP đã được gửi đến\n'),
              TextSpan(text: _emailCtrl.text.isEmpty ? 'your@email.com' : _emailCtrl.text, style: GoogleFonts.dmSans(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) => _OtpBox(controller: _otpCtrls[i], index: i, hasError: _otpError != null)),
        ),
        if (_otpError != null) ...[
          const SizedBox(height: 12),
          Center(child: Text(_otpError!, style: GoogleFonts.dmSans(color: Colors.red.shade600, fontSize: 13, fontWeight: FontWeight.w600))),
        ],
        const SizedBox(height: 16),
        Center(
          child: _canResend
              ? TextButton(onPressed: () async { await ApiService.forgotPassword(_emailCtrl.text); _startTimer(); }, child: const Text('Gửi lại mã'))
              : Text('Gửi lại sau $_resendTimer giây', style: GoogleFonts.dmSans(fontSize: 13, color: colorScheme.onSurface.withOpacity(0.4))),
        ),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: _loading ? null : _nextStep, child: _loading ? const _LoadingIndicator() : const Text('Xác minh')),
      ],
    );
  }

  // ── STEP 2: Mật khẩu mới ─────────────────────────────────────────────────────
  Widget _buildNewPasswordStep(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepIcon(icon: Icons.lock_reset_rounded),
        const SizedBox(height: 24),
        Text('Tạo mật khẩu mới', style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w800, color: colorScheme.onSurface)),
        const SizedBox(height: 8),
        Text('Mật khẩu mới phải khác mật khẩu cũ và tối thiểu 8 ký tự.', style: GoogleFonts.dmSans(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.6))),
        const SizedBox(height: 32),
        const _FieldLabel('Mật khẩu mới'),
        const SizedBox(height: 8),
        TextField(
          controller: _newPassCtrl, obscureText: _obscureNew,
          style: TextStyle(color: colorScheme.onSurface),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Tối thiểu 8 ký tự',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(icon: Icon(_obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20), onPressed: () => setState(() => _obscureNew = !_obscureNew)),
          ),
        ),
        const SizedBox(height: 8),
        _PasswordStrengthBar(password: _newPassCtrl.text),
        const SizedBox(height: 16),
        const _FieldLabel('Xác nhận mật khẩu mới'),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmPassCtrl, obscureText: _obscureConf,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Nhập lại mật khẩu',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(icon: Icon(_obscureConf ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20), onPressed: () => setState(() => _obscureConf = !_obscureConf)),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(onPressed: _loading ? null : _nextStep, child: _loading ? const _LoadingIndicator() : const Text('Đổi mật khẩu')),
      ],
    );
  }

  // ── STEP 3: Thành công ────────────────────────────────────────────────────────
  Widget _buildSuccessStep(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.12), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 56),
          ),
        ),
        const SizedBox(height: 28),
        Text('Đổi mật khẩu thành công!', textAlign: TextAlign.center, style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w800, color: colorScheme.onSurface)),
        const SizedBox(height: 12),
        Text('Mật khẩu của bạn đã được cập nhật.\nHãy đăng nhập lại để tiếp tục.', textAlign: TextAlign.center, style: GoogleFonts.dmSans(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.6), height: 1.6)),
        const SizedBox(height: 48),
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Về đăng nhập')),
      ],
    );
  }
}

// ─── Step progress indicator (Sửa màu line và circle) ─────────────────────────
class _StepProgress extends StatelessWidget {
  final int current;
  const _StepProgress({required this.current});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: List.generate(3, (i) {
        final done = i < current;
        final active = i == current;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done || active ? AppColors.primary : theme.dividerColor.withOpacity(0.1),
                      ),
                      child: Center(
                        child: done ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                            : Text('${i + 1}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.primary)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(['Email', 'OTP', 'Mật khẩu'][i], style: TextStyle(fontSize: 11, fontWeight: active || done ? FontWeight.w600 : FontWeight.w400, color: active || done ? AppColors.primary : theme.hintColor)),
                  ],
                ),
              ),
              if (i < 2) Expanded(child: Container(height: 2, margin: const EdgeInsets.only(bottom: 20), color: i < current ? AppColors.primary : theme.dividerColor)),
            ],
          ),
        );
      }),
    );
  }
}

// ─── OTP input box (Sửa màu viền và màu số) ────────────────────────────
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final int index;
  final bool hasError;

  const _OtpBox({required this.controller, required this.index, this.hasError = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 46, height: 54,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w700, color: hasError ? Colors.red.shade600 : theme.colorScheme.onSurface),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: hasError ? Colors.red.shade600 : theme.dividerColor, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: hasError ? Colors.red.shade600 : AppColors.primary, width: 2),
          ),
        ),
        onChanged: (v) {
          if (v.isNotEmpty && index < 5) FocusScope.of(context).nextFocus();
          if (v.isEmpty && index > 0) FocusScope.of(context).previousFocus();
          if (index == 5 && v.isNotEmpty) FocusScope.of(context).unfocus();
        },
      ),
    );
  }
}

// ─── Helpers (Sửa màu icon container và label) ──────────────────────────
class _StepIcon extends StatelessWidget {
  final IconData icon;
  const _StepIcon({required this.icon});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 64, height: 64,
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1C1C1E) : AppColors.primaryContainer, borderRadius: BorderRadius.circular(20)),
      child: Icon(icon, color: AppColors.primary, size: 30),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface));
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();
  @override
  Widget build(BuildContext context) => const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5));
}

class _PasswordStrengthBar extends StatelessWidget {
  final String password;
  const _PasswordStrengthBar({required this.password});
  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#\$%^&*]'))) score++;
    final color = [AppColors.divider, AppColors.error, AppColors.warning, AppColors.success, AppColors.success][score];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: List.generate(4, (i) => Expanded(child: Container(height: 4, margin: EdgeInsets.only(right: i < 3 ? 4 : 0), decoration: BoxDecoration(color: i < score ? color : Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(2)))))),
      const SizedBox(height: 5),
      Text('Độ mạnh: ${['', 'Yếu', 'Trung bình', 'Mạnh', 'Rất mạnh'][score]}', style: GoogleFonts.dmSans(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    ]);
  }
}