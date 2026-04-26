class HistoryItem {
  final int id;
  final DateTime createdAt;
  final String problemContent;
  final String inputType;
  final String result;
  final List<String> steps;
  final String latex;

  HistoryItem({
    required this.id,
    required this.createdAt,
    required this.problemContent,
    required this.inputType,
    required this.result,
    required this.steps,
    required this.latex,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      problemContent: json['problem_content'] ?? "",
      inputType: json['input_type'] ?? "text",
      result: json['result'] ?? "",
      // Tách chuỗi từ Database (cách nhau bởi dấu |) thành danh sách các bước
      steps: (json['steps'] as String?)?.split('|')
          .where((s) => s.trim().isNotEmpty)
          .toList() ?? [],
      latex: json['latex'] ?? "",
    );
  }
}