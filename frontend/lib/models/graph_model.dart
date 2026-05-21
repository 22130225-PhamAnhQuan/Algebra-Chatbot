class GraphResponse {
  final bool success;
  final String result;
  final List<String> steps;
  final String? image;
  final dynamic degree;
  final String solver;
  final Map<String, dynamic> features;

  GraphResponse({
    required this.success,
    required this.result,
    required this.steps,
    required this.image,
    required this.degree,
    required this.solver,
    required this.features,
  });

  factory GraphResponse.fromJson(Map<String, dynamic> json) {
    return GraphResponse(
      success: json['success'] ?? false,
      result: json['result'] ?? "",
      steps: List<String>.from(json['steps'] ?? []),
      image: json['image'],
      degree: json['degree'],
      solver: json['solver'] ?? "",
      features: json['features'] ?? {},
    );
  }
}