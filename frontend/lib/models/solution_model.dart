class SolutionModel {
  final int? problemId;
  final String result;
  final List<StepModel> steps;
  final String latex;
  final String? image;
  final String? solver;
  final String? type;
  final Map<String, dynamic>? features;

  SolutionModel({
    this.problemId,
    required this.result,
    required this.steps,
    required this.latex,
    this.image,
    this.solver,
    this.type,
    this.features,
  });

  factory SolutionModel.fromJson(Map<String, dynamic> json) {
    // Bóc tách lớp bọc dữ liệu từ API Backend
    final data = json['data'] ?? json['solution'] ?? json;

    // Ưu tiên đọc mảng công thức xịn "steps_latex" trước, nếu rỗng thì fallback về "steps"
    final rawSteps = data['steps_latex'] ?? data['steps'];

    List<StepModel> parsedSteps = [];

    if (rawSteps is List) {
      parsedSteps = rawSteps.asMap().entries.map((entry) {
        final index = entry.key;
        final s = entry.value;

        if (s is Map<String, dynamic>) {
          return StepModel.fromJson(s);
        }

        return StepModel(
          stepNumber: index + 1,
          description: '',
          latex: s.toString(),
        );
      }).toList();
    }
    else if (rawSteps is String) {
      parsedSteps = rawSteps
          .split('\n')
          .where((e) => e.trim().isNotEmpty)
          .toList()
          .asMap()
          .entries
          .map((entry) => StepModel(
        stepNumber: entry.key + 1,
        description: entry.value.trim(),
        latex: '',
      ))
          .toList();
    }

    return SolutionModel(
      problemId: json['problem_id'] is int ? json['problem_id'] : null,
      result: data['result']?.toString() ?? "",
      steps: parsedSteps,
      latex: data['latex']?.toString() ?? "",

      image: data['graph_image']?.toString() ?? data['image']?.toString(),

      solver: data['solver']?.toString(),
      type: data['type']?.toString(),
      features: data['features'] is Map<String, dynamic> ? data['features'] : null,
    );
  }

  bool get isGraph {
    return hasImage;
  }

  bool get hasImage {
    return image != null && image!.isNotEmpty;
  }
}

class StepModel {
  final int stepNumber;
  final String description;
  final String latex;

  StepModel({
    required this.stepNumber,
    required this.description,
    required this.latex,
  });

  factory StepModel.fromJson(Map<String, dynamic> json) {
    return StepModel(
      stepNumber: json['step_number'] ?? 0,
      description: json['description']?.toString() ?? "",
      latex: json['latex']?.toString() ?? "",
    );
  }
}