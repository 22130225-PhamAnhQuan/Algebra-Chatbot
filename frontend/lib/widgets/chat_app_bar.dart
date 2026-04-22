// lib/widgets/chat_app_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

/// AppBar của ChatScreen
/// - Logo ∑ ở leading
/// - Title + subtitle "Online"
/// - Nút history và avatar user
class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onHistoryTap;
  final VoidCallback? onProfileTap;
  final String userInitial;

  const ChatAppBar({
    super.key,
    this.onHistoryTap,
    this.onProfileTap,
    this.userInitial = 'A',
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text(
              '∑',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Algebra Chatbot',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'Online • Sẵn sàng giải toán',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history_rounded),
          onPressed: onHistoryTap,
          tooltip: 'Lịch sử',
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  userInitial,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
