import 'dart:io';
import 'package:flutter/material.dart';
import '../models/solution_model.dart';
import '../services/solver_service.dart';

class SolverProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<SolutionModel> _history = [];
  List<SolutionModel> get history => List.unmodifiable(_history);

  int? _gradeId;
  int? _chapterId;
  int? _lessonId;

  int? get gradeId => _gradeId;
  int? get chapterId => _chapterId;
  int? get lessonId => _lessonId;

  void setGrade(int gradeId) {
    _gradeId = gradeId;
    _chapterId = null;
    _lessonId = null;
    notifyListeners();
  }

  void setChapter(int chapterId) {
    _chapterId = chapterId;
    _lessonId = null;
    notifyListeners();
  }

  void setLesson(int lessonId) {
    _lessonId = lessonId;
    notifyListeners();
  }

  Future<SolutionModel?> solve({
    String? text,
    File? image,
    required String token,
    int? gradeId,
    int? chapterId,
    int? lessonId,
  }) async {
    if ((text == null || text.trim().isEmpty) && image == null) {
      _error = "Không có dữ liệu đầu vào";
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await SolverService.solve(
        text: text,
        image: image,
        token: token,
        gradeId: _gradeId,
        chapterId: _chapterId,
        lessonId: _lessonId,
      );

      _history = [..._history, result];
      notifyListeners();

      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearHistory() {
    _history = [];
    notifyListeners();
  }
}
