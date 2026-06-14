import 'dart:convert';

import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';

import '../models/grade_model.dart';
import '../models/chapter_model.dart';
import '../models/lesson_model.dart';
import '../models/lesson_detail_model.dart';

class CurriculumService {
  static Future<List<GradeModel>> getGrades() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/curriculum/grades');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));

      throw body['detail'] ?? 'Lỗi tải danh sách lớp';
    }

    final body = jsonDecode(utf8.decode(response.bodyBytes));

    if (body is! List) {
      throw 'Invalid grades format';
    }

    return body.map<GradeModel>((item) => GradeModel.fromJson(item)).toList();
  }

  static Future<List<ChapterModel>> getChapters(int gradeId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/curriculum/grades/$gradeId/chapters',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));

      throw body['detail'] ?? 'Lỗi tải danh sách chương';
    }

    final body = jsonDecode(utf8.decode(response.bodyBytes));

    if (body is! List) {
      throw 'Invalid chapters format';
    }

    return body
        .map<ChapterModel>((item) => ChapterModel.fromJson(item))
        .toList();
  }

  static Future<List<LessonModel>> getLessons(int chapterId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/curriculum/chapters/$chapterId/lessons',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));

      throw body['detail'] ?? 'Lỗi tải danh sách bài học';
    }

    final body = jsonDecode(utf8.decode(response.bodyBytes));

    if (body is! List) {
      throw 'Invalid lessons format';
    }

    return body.map<LessonModel>((item) => LessonModel.fromJson(item)).toList();
  }

  static Future<LessonDetailModel> getLessonDetail(int lessonId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/curriculum/lessons/$lessonId');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));

      throw body['detail'] ?? 'Lỗi tải chi tiết bài học';
    }

    final body = jsonDecode(utf8.decode(response.bodyBytes));

    return LessonDetailModel.fromJson(body);
  }
}
