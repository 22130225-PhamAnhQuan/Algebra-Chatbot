class LessonDetailModel {
  final int id;
  final int lessonNumber;
  final String title;
  final String? theory;
  final String? formula;
  final String? example;

  LessonDetailModel({
    required this.id,
    required this.lessonNumber,
    required this.title,
    this.theory,
    this.formula,
    this.example,
  });

  factory LessonDetailModel.fromJson( Map<String, dynamic> json, ) {
    return LessonDetailModel(
      id: json['id'],
      lessonNumber: json['lesson_number'],
      title: json['title'],
      theory: json['theory'],
      formula: json['formula'],
      example: json['example'],
    );
  }
}