class SolutionModel {
  final String result;
  final List<StepModel> steps;
  final String latex;

  // GRAPH SUPPORT
  final String? image;
  final String? solver;
  final String? type;
  final Map<String, dynamic>? features;

  SolutionModel({
    required this.result,
    required this.steps,
    required this.latex,
    this.image,
    this.solver,
    this.type,
    this.features,
  });

  factory SolutionModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json['solution'] ?? json;

    final rawSteps = data['steps'];

    List<StepModel> parsedSteps = [];
    if (rawSteps is List) {
      parsedSteps = rawSteps.asMap().entries.map((entry) {
        final index = entry.key;
        final s = entry.value;

        // STEP JSON
        if (s is Map<String, dynamic>) {
          return StepModel.fromJson(s);
        }

        // STEP STRING
        return StepModel(
          stepNumber: index + 1,
          description: s.toString(),
          latex: '',
        );
      }).toList();
    }

    // =========================
    // STRING STEPS
    // =========================
    else if (rawSteps is String) {
      parsedSteps = rawSteps
          .split('\n')
          .where((e) => e.trim().isNotEmpty)
          .map((s) => StepModel(
        stepNumber: 0,
        description: s.trim(),
        latex: '',
      ))
          .toList();
    }

    return SolutionModel(
      result: data['result']?.toString() ?? "",
      steps: parsedSteps,
      latex: data['latex']?.toString() ?? "",

      // GRAPH
      image: data['image']?.toString(),
      solver: data['solver']?.toString(),
      type: data['type']?.toString(),

      // FEATURES
      features: data['features'] is Map<String, dynamic>
          ? data['features']
          : null,
    );
  }

  // =========================
  // HELPERS
  // =========================

  bool get isGraph {
    return solver != null &&
        solver!.startsWith("graph");
  }

  bool get hasImage {
    return image != null &&
        image!.isNotEmpty;
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