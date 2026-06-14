
import 'solution_model.dart'; // Phải có StepModel ở đây

class HistoryItem {
  final int id;
  final DateTime createdAt;
  final String problemContent;
  final String inputType;
  final String result;
  final List<StepModel> steps;
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
    var rawSteps = json['steps'];
    List<StepModel> parsedSteps = [];

    if (rawSteps is List) {
      for (var s in rawSteps) {
        if (s is Map<String, dynamic>) {
          parsedSteps.add(StepModel.fromJson(s));
        } else if (s is String) {
          parsedSteps.add(StepModel(
            stepNumber: parsedSteps.length + 1,
            description: s,
            latex: '',
          ));
        }
      }
    } else if (rawSteps is String) {
      var parts = rawSteps.split('|').where((s) => s.trim().isNotEmpty).toList();
      for (int i = 0; i < parts.length; i++) {
        parsedSteps.add(StepModel(stepNumber: i + 1, description: parts[i].trim(), latex: ''));
      }
    }

    return HistoryItem(
      id: json['id'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      problemContent: json['problem_content'] ?? "",
      inputType: json['input_type'] ?? "text",
      result: json['result'] ?? "",
      steps: parsedSteps, // LUÔN TRẢ VỀ LIST<STEPMODEL>
      latex: json['latex'] ?? "",
    );
  }
}