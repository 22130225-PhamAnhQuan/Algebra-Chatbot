class LessonModel {
  final int id;
  final int lessonNumber;
  final String title;

  LessonModel({
    required this.id,
    required this.lessonNumber,
    required this.title, });

  factory LessonModel.fromJson( Map<String, dynamic> json, ) {
    return LessonModel(
      id: json['id'],
      lessonNumber: json['lesson_number'],
      title: json['title'],
    );
  }
}