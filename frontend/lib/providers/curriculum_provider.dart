import 'package:flutter/material.dart';

import '../models/grade_model.dart';
import '../models/chapter_model.dart';
import '../models/lesson_model.dart';
import '../models/lesson_detail_model.dart';

import '../services/curriculum_service.dart';

class CurriculumProvider extends ChangeNotifier {
  bool _isLoading = false;

  String? _error;

  List<GradeModel> _grades = [];

  List<ChapterModel> _chapters = [];

  Map<int, List<LessonModel>> _lessonsByChapter = {};

  Map<int, List<LessonModel>> get lessonsByChapter =>
      _lessonsByChapter;

  LessonDetailModel? _lessonDetail;

  bool get isLoading => _isLoading;

  String? get error => _error;

  List<GradeModel> get grades => _grades;

  List<ChapterModel> get chapters => _chapters;

  LessonDetailModel? get lessonDetail => _lessonDetail;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadGrades() async {
    try {
      _setLoading(true);

      _error = null;

      _grades = await CurriculumService.getGrades();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadChapters(int gradeId) async {
    try {
      _setLoading(true);

      _error = null;

      _chapters = await CurriculumService.getChapters(gradeId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadLessons(
      int chapterId,
      ) async {
    try {
      _error = null;

      final lessons =
      await CurriculumService.getLessons(
        chapterId,
      );

      _lessonsByChapter[chapterId] =
          lessons;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  Future<void> loadLessonDetail(int lessonId) async {
    try {
      _setLoading(true);

      _error = null;

      _lessonDetail = await CurriculumService.getLessonDetail(lessonId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void clearLessonDetail() {
    _lessonDetail = null;

    notifyListeners();
  }

  void clearLessons() {
    _lessonsByChapter.clear();

    notifyListeners();
  }

  void clearChapters() {
    _chapters = [];

    notifyListeners();
  }
}
