// lib/models/solution_model.dart
class SolutionModel {
  final String result;
  final List<String> steps;
  final String latex;

  SolutionModel({
    required this.result,
    required this.steps,
    required this.latex,
  });

  factory SolutionModel.fromJson(Map<String, dynamic> json) {
    // API của bạn trả về data bọc ngoài (thấy từ Swagger)
    var data = json['data'] ?? json; // Dự phòng nếu sau này backend bỏ bọc 'data'

    // Xử lý an toàn mảng steps
    var rawSteps = data['steps'] ?? [];
    List<String> parsedSteps = [];

    if (rawSteps is List) {
      parsedSteps = rawSteps.map((s) => s.toString()).toList();
    } else if (rawSteps is String) {
      // Xử lý trường hợp backend trả về chuỗi nối bằng dấu |
      parsedSteps = rawSteps.split('|').where((s) => s.isNotEmpty).toList();
    }

    return SolutionModel(
      result: data['result']?.toString() ?? "",
      steps: parsedSteps,
      latex: data['latex']?.toString() ?? "",
    );
  }
}