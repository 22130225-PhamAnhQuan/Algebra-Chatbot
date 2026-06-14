class ChapterModel {
  final int id;
  final int chapterNumber;
  final String title;

  ChapterModel({
    required this.id,
    required this.chapterNumber,
    required this.title,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json,) {
    return ChapterModel(
      id: json['id'],
      chapterNumber: json['chapter_number'],
      title: json['title'],
    );
  }
}
