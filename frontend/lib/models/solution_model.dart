class ProblemModel {
  final int id;
  final String content;
  final String inputType; // 'text', 'image'
  final DateTime createdAt;

  ProblemModel({required this.id, required this.content, required this.inputType, required this.createdAt});

  factory ProblemModel.fromJson(Map<String, dynamic> json) => ProblemModel(
    id: json['id'],
    content: json['content'],
    inputType: json['input_type'],
    createdAt: DateTime.parse(json['created_at']),
  );
}

class SolutionModel {
  final int id;
  final int problemId;
  final String? result;
  final String? steps;
  final String? latex;
  final String? model;

  SolutionModel({required this.id, required this.problemId, this.result, this.steps, this.latex, this.model});

  factory SolutionModel.fromJson(Map<String, dynamic> json) => SolutionModel(
    id: json['id'],
    problemId: json['problem_id'],
    result: json['result'],
    steps: json['steps'],
    latex: json['latex'],
    model: json['model'],
  );
}