// // lib/widgets/chat_bubble.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import '../models/models.dart';
// import '../core/theme/app_theme.dart';
//
// /// Bubble tin nhắn — tự động căn trái (bot) hoặc phải (user)
// /// Long-press để copy nội dung
// class ChatBubble extends StatelessWidget {
//   final MessageModel message;
//   const ChatBubble({super.key, required this.message});
//
//   bool get isUser => message.sender == MessageSender.user;
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       child: Row(
//         mainAxisAlignment:
//             isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           if (!isUser) ...[const BotAvatar(), const SizedBox(width: 8)],
//           Flexible(
//             child: Column(
//               crossAxisAlignment:
//                   isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//               children: [
//                 GestureDetector(
//                   onLongPress: () {
//                     Clipboard.setData(ClipboardData(text: message.content));
//                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                       content: Text('Đã sao chép',
//                           style: GoogleFonts.dmSans(fontSize: 13)),
//                       duration: const Duration(seconds: 1),
//                       behavior: SnackBarBehavior.floating,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10)),
//                     ));
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 16, vertical: 12),
//                     constraints: BoxConstraints(
//                         maxWidth: MediaQuery.of(context).size.width * 0.72),
//                     decoration: BoxDecoration(
//                       color: isUser ? AppColors.userBubble : AppColors.botBubble,
//                       borderRadius: BorderRadius.only(
//                         topLeft: const Radius.circular(20),
//                         topRight: const Radius.circular(20),
//                         bottomLeft: Radius.circular(isUser ? 20 : 4),
//                         bottomRight: Radius.circular(isUser ? 4 : 20),
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: (isUser ? AppColors.primary : Colors.indigo)
//                               .withOpacity(0.08),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: _BubbleContent(
//                         content: message.content, isUser: isUser),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   DateFormat('HH:mm').format(message.timestamp),
//                   style: GoogleFonts.dmSans(
//                       fontSize: 11, color: AppColors.textHint),
//                 ),
//               ],
//             ),
//           ),
//           if (isUser) ...[const SizedBox(width: 8), const UserAvatar()],
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Nội dung bubble — parse **bold** đơn giản ───────────────────────────────
//
// class _BubbleContent extends StatelessWidget {
//   final String content;
//   final bool isUser;
//   const _BubbleContent({required this.content, required this.isUser});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: content.split('\n').map((line) {
//         if (line.startsWith('**') && line.endsWith('**')) {
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 4),
//             child: Text(
//               line.replaceAll('**', ''),
//               style: GoogleFonts.dmSans(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w700,
//                 color: isUser ? AppColors.userText : AppColors.botText,
//               ),
//             ),
//           );
//         }
//         if (line.isEmpty) return const SizedBox(height: 6);
//         return Text(
//           line,
//           style: GoogleFonts.dmSans(
//             fontSize: 14,
//             color: isUser ? AppColors.userText : AppColors.botText,
//             height: 1.5,
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
//
// // ─── Avatars ──────────────────────────────────────────────────────────────────
//
// class BotAvatar extends StatelessWidget {
//   const BotAvatar({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 32,
//       height: 32,
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [AppColors.primary, AppColors.primaryLight],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: const Center(
//         child: Text('∑', style: TextStyle(color: Colors.white, fontSize: 16)),
//       ),
//     );
//   }
// }
//
// class UserAvatar extends StatelessWidget {
//   final String initial;
//   const UserAvatar({super.key, this.initial = 'A'});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 32,
//       height: 32,
//       decoration: BoxDecoration(
//         color: AppColors.primaryContainer,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Center(
//         child: Text(
//           initial,
//           style: const TextStyle(
//             color: AppColors.primary,
//             fontSize: 14,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─── TypingIndicator — 3 chấm nhảy stagger ───────────────────────────────────
//
// class TypingIndicator extends StatefulWidget {
//   const TypingIndicator({super.key});
//
//   @override
//   State<TypingIndicator> createState() => _TypingIndicatorState();
// }
//
// class _TypingIndicatorState extends State<TypingIndicator>
//     with TickerProviderStateMixin {
//   late List<AnimationController> _controllers;
//   late List<Animation<double>> _anims;
//
//   @override
//   void initState() {
//     super.initState();
//     _controllers = List.generate(
//       3,
//       (_) => AnimationController(
//           vsync: this, duration: const Duration(milliseconds: 500)),
//     );
//     _anims = _controllers
//         .map((c) => Tween<double>(begin: 0, end: -6)
//             .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)))
//         .toList();
//     for (var i = 0; i < 3; i++) {
//       Future.delayed(Duration(milliseconds: i * 180), () {
//         if (mounted) _controllers[i].repeat(reverse: true);
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     for (final c in _controllers) c.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       child: Row(
//         children: [
//           const BotAvatar(),
//           const SizedBox(width: 8),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//             decoration: const BoxDecoration(
//               color: AppColors.botBubble,
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(20),
//                 topRight: Radius.circular(20),
//                 bottomRight: Radius.circular(20),
//                 bottomLeft: Radius.circular(4),
//               ),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: List.generate(
//                 3,
//                 (i) => AnimatedBuilder(
//                   animation: _anims[i],
//                   builder: (_, __) => Transform.translate(
//                     offset: Offset(0, _anims[i].value),
//                     child: Container(
//                       width: 7,
//                       height: 7,
//                       margin: const EdgeInsets.symmetric(horizontal: 3),
//                       decoration: BoxDecoration(
//                         color: AppColors.primary.withOpacity(0.5),
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
