class ChatMessage {
  final int? id;
  final String sender; // 'USER' hoặc 'BOT'
  final String content;
  final String type;   // 'text' hoặc 'latex'
  final DateTime createdAt;

  ChatMessage({
    this.id,
    required this.sender,
    required this.content,
    required this.type,
    required DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      sender: json['sender'],
      content: json['content'],
      type: json['type'] ?? 'text',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}