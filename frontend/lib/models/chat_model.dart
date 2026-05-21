import 'package:algebra_chatbot/models/solution_model.dart';

class ChatMessage {
  final int? id;
  final String sender; // 'USER' hoặc 'BOT'
  final String content;
  final String type;   // 'text' hoặc 'latex'
  final String? imageUrl; // MỚI: Thêm trường này để chứa link ảnh
  final DateTime createdAt;
  final SolutionModel? solution;

  ChatMessage({
    this.id,
    required this.sender,
    required this.content,
    required this.type,
    this.imageUrl, // Thêm vào constructor
    required DateTime? createdAt,
    this.solution,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      sender: json['sender'],
      content: json['content'],
      type: json['type'] ?? 'text',
      // MỚI: Backend trả về image_url thì gán vào đây
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}