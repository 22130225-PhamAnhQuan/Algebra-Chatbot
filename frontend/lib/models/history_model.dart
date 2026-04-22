class HistoryModel {
  final int id;
  final String problemContent;
  final String inputType;
  final String result;
  final String steps;
  final String latex;
  final DateTime createdAt;

  HistoryModel({
    required this.id,
    required this.problemContent,
    required this.inputType,
    required this.result,
    required this.steps,
    required this.latex,
    required this.createdAt,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) => HistoryModel(
    id: json['id'],
    problemContent: json['problem_content'],
    inputType: json['input_type'],
    result: json['result'] ?? '',
    steps: json['steps'] ?? '',
    latex: json['latex'] ?? '',
    createdAt: DateTime.parse(json['created_at']),
  );
}