// // lib/widgets/history_card.dart
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import '../models/models.dart';
// import '../core/theme/app_theme.dart';
//
// /// Card 1 item lịch sử — hỗ trợ swipe-to-delete
// class HistoryCard extends StatefulWidget {
//   final HistoryModel item;
//   final Duration animDelay;
//   final VoidCallback onDelete;
//   final VoidCallback? onTap;
//
//   const HistoryCard({
//     super.key,
//     required this.item,
//     this.animDelay = Duration.zero,
//     required this.onDelete,
//     this.onTap,
//   });
//
//   @override
//   State<HistoryCard> createState() => _HistoryCardState();
// }
//
// class _HistoryCardState extends State<HistoryCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//   late Animation<double> _fade;
//   late Animation<Offset> _slide;
//
//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 380));
//     _fade = Tween<double>(begin: 0, end: 1)
//         .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
//     _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
//         .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
//     Future.delayed(widget.animDelay, () {
//       if (mounted) _ctrl.forward();
//     });
//   }
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }
//
//   String _timeAgo(DateTime dt) {
//     final diff = DateTime.now().difference(dt);
//     if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
//     if (diff.inHours < 24) return '${diff.inHours} giờ trước';
//     if (diff.inDays == 1) return 'Hôm qua';
//     return DateFormat('dd/MM/yyyy').format(dt);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _fade,
//       child: SlideTransition(
//         position: _slide,
//         child: Dismissible(
//           key: Key(widget.item.id),
//           direction: DismissDirection.endToStart,
//           background: Container(
//             margin: const EdgeInsets.only(bottom: 12),
//             padding: const EdgeInsets.only(right: 20),
//             decoration: BoxDecoration(
//               color: AppColors.error,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             alignment: Alignment.centerRight,
//             child: const Icon(Icons.delete_rounded, color: Colors.white),
//           ),
//           onDismissed: (_) => widget.onDelete(),
//           child: Container(
//             margin: const EdgeInsets.only(bottom: 12),
//             decoration: BoxDecoration(
//               color: AppColors.surface,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: AppColors.divider),
//             ),
//             child: InkWell(
//               onTap: widget.onTap,
//               borderRadius: BorderRadius.circular(16),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   children: [
//                     // Icon
//                     Container(
//                       width: 44,
//                       height: 44,
//                       decoration: BoxDecoration(
//                         color: AppColors.primaryContainer,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Center(
//                         child: Text('∑',
//                             style: TextStyle(
//                                 fontSize: 20, color: AppColors.primary)),
//                       ),
//                     ),
//                     const SizedBox(width: 14),
//                     // Content
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             widget.item.problem,
//                             style: GoogleFonts.dmSans(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: AppColors.textPrimary,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 5),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 3),
//                             decoration: BoxDecoration(
//                               color: AppColors.success.withOpacity(0.12),
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Text(
//                               widget.item.shortAnswer,
//                               style: GoogleFonts.dmSans(
//                                 fontSize: 12,
//                                 color: AppColors.success,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 5),
//                           Text(
//                             _timeAgo(widget.item.timestamp),
//                             style: GoogleFonts.dmSans(
//                               fontSize: 11,
//                               color: AppColors.textHint,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const Icon(Icons.chevron_right_rounded,
//                         color: AppColors.textHint),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
