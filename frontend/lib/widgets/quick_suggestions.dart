// lib/widgets/quick_suggestions.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

/// Gợi ý bài toán mẫu — hiển thị khi cuộc chat còn ít tin nhắn
class QuickSuggestions extends StatelessWidget {
  final ValueChanged<String> onTap;

  static const _items = [
    'Solve x² - 4 = 0',
    'Factor x² + 5x + 6',
    '∫(2x + 1)dx',
    'log₂(8) = ?',
    "f'(x) của 3x³",
  ];

  const QuickSuggestions({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => ActionChip(
          label: Text(
            _items[i],
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: AppColors.primaryContainer,
          side: BorderSide.none,
          onPressed: () => onTap(_items[i]),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}
