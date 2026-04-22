class Formula {
  final int id;
  final int grade;
  final String title;
  final String formula;
  final String explanation;
  final String example;

  Formula({
    required this.id,
    required this.grade,
    required this.title,
    required this.formula,
    required this.explanation,
    required this.example,
  });

  factory Formula.fromJson(Map<String, dynamic> json) => Formula(
    id: json['id'],
    grade: json['grade'],
    title: json['title'],
    formula: json['formula'],
    explanation: json['explanation'] ?? '',
    example: json['example'] ?? '',
  );
}