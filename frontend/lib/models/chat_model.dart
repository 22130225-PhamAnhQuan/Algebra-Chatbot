class ConversationModel {
  final int id;
  final String? title;
  final DateTime createdAt;

  ConversationModel({required this.id, this.title, required this.createdAt});

  factory ConversationModel.fromJson(Map<String, dynamic> json) => ConversationModel(
    id: json['id'],
    title: json['title'],
    createdAt: DateTime.parse(json['created_at']),
  );
}

class MessageModel {
  final int id;
  final int conversationId;
  final String sender; // 'USER' hoặc 'BOT'
  final String content;
  final String type; // 'text', 'image', 'latex'
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.content,
    required this.type,
    required this.createdAt,
  });

  bool get isBot => sender == 'BOT';

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    id: json['id'],
    conversationId: json['conversation_id'],
    sender: json['sender'],
    content: json['content'],
    type: json['type'] ?? 'text',
    createdAt: DateTime.parse(json['created_at']),
  );
}