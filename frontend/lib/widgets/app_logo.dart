// lib/widgets/app_logo.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

/// Logo hình vuông bo góc với ký hiệu ∑
/// Dùng ở SplashScreen, LoginScreen, RegisterScreen
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({super.key, this.size = 72, this.showText = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '∑',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            'Algebra',
            style: GoogleFonts.dmSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'Chatbot',
            style: GoogleFonts.dmSans(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }
}
