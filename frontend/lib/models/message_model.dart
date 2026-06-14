class MessageModel {
  final int? id;
  final int? conversationId;
  final String role;
  final String content;
  final String? imageUrl;
  final bool isSolution;

  MessageModel({
    this.id,
    this.conversationId,
    required this.role,
    required this.content,
    this.imageUrl,
    this.isSolution = false,
  });

  factory MessageModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return MessageModel(
      id: json["id"],
      conversationId: json["conversation_id"],
      role: json["role"] ?? "",
      content: json["content"] ?? "",
      imageUrl: json["image_url"],
      isSolution: json["is_solution"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "conversation_id": conversationId,
      "role": role,
      "content": content,
      "image_url": imageUrl,
      "is_solution": isSolution,
    };
  }

  bool get isUser => role == "user";

  bool get isAssistant => role == "assistant";
}