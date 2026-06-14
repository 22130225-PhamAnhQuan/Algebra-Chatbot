class ConversationModel {
  final int id;
  final int userId;
  final int problemId;
  final String title;

  ConversationModel({
    required this.id,
    required this.userId,
    required this.problemId,
    required this.title,
  });

  factory ConversationModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return ConversationModel(
      id: json["id"],
      userId: json["user_id"],
      problemId: json["problem_id"],
      title: json["title"] ?? "",
    );
  }
}