
import 'solution_model.dart';

class HistoryItem {
  final int id;
  final DateTime createdAt;
  final String problemContent;
  final String inputType;
  final String result;
  final List<StepModel> steps;
  final String latex;
  final String? graphImage;

  HistoryItem({
    required this.id,
    required this.createdAt,
    required this.problemContent,
    required this.inputType,
    required this.result,
    required this.steps,
    required this.latex,
    required this.graphImage,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    var rawSteps = json['steps'];
    List<StepModel> parsedSteps = [];

    if (rawSteps != null) {
      if (rawSteps is List) {
        for (var s in rawSteps) {
          if (s is Map<String, dynamic>) {
            parsedSteps.add(StepModel.fromJson(s));
          } else {
            parsedSteps.add(StepModel(
              stepNumber: parsedSteps.length + 1,
              description: s.toString(),
              latex: '',
            ));
          }
        }
      } else if (rawSteps is String) {
        var parts = rawSteps.split('|').where((s) => s.trim().isNotEmpty).toList();
        for (int i = 0; i < parts.length; i++) {
          parsedSteps.add(StepModel(
              stepNumber: i + 1,
              description: parts[i].trim(),
              latex: ''
          ));
        }
      }
    }

    return HistoryItem(
      id: json['id'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      problemContent: json['problem_content'] ?? "Không có nội dung",
      inputType: json['input_type'] ?? "text",
      result: json['result']?.toString() ?? "",
      steps: parsedSteps,
      latex: json['latex'] ?? "",
      graphImage: json['graph_image'],
    );
  }
}