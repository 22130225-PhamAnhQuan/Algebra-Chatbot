import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  bool _isLoading = false;

  Map<String, dynamic>? _stats;

  List<dynamic> _users = [];
  List<dynamic> _aiLogs = [];
  List<dynamic> _histories = [];

  List<dynamic> _grades = [];
  List<dynamic> _chapters = [];
  List<dynamic> _lessons = [];

  int? _selectedGradeId;
  int? _selectedChapterId;

  bool get isLoading => _isLoading;

  Map<String, dynamic>? get stats => _stats;

  List<dynamic> get users => _users;

  List<dynamic> get aiLogs => _aiLogs;

  List<dynamic> get histories => _histories;

  List<dynamic> get grades => _grades;

  List<dynamic> get chapters => _chapters;

  List<dynamic> get lessons => _lessons;

  int? get selectedGradeId => _selectedGradeId;

  int? get selectedChapterId => _selectedChapterId;

  Future<void> fetchAllAdminData(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final statsData = await _adminService.getDashboardStats(token);

      if (statsData != null && statsData['success'] == true) {
        _stats = statsData['data'];
      }

      _users = await _adminService.getAllUsers(token) ?? [];

      _aiLogs = await _adminService.getAILogs(token) ?? [];

      _histories = await _adminService.getAllHistories(token) ?? [];
    } catch (e) {
      debugPrint("AdminProvider Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> toggleUser(String token, int userId, int index) async {
    final success = await _adminService.toggleUserStatus(token, userId);

    if (success) {
      _users[index]['is_active'] = !_users[index]['is_active'];

      notifyListeners();
    }

    return success;
  }

  Future<void> loadGrades(String token) async {
    _isLoading = true;
    notifyListeners();

    _grades = await _adminService.getGrades(token) ?? [];

    print("GRADES = $_grades");

    _chapters.clear();
    _lessons.clear();

    _selectedGradeId = null;
    _selectedChapterId = null;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectGrade(String token, int gradeId) async {
    _selectedGradeId = gradeId;

    await loadChapters(token, gradeId);
  }

  Future<void> loadChapters(String token, int gradeId) async {
    _isLoading = true;
    notifyListeners();

    _chapters = await _adminService.getChapters(token, gradeId) ?? [];

    print("CHAPTERS = $_chapters");

    _lessons.clear();

    _selectedChapterId = null;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectChapter(String token, int chapterId) async {
    _selectedChapterId = chapterId;

    await loadLessons(token, chapterId);
  }

  Future<void> loadLessons(String token, int chapterId) async {
    _isLoading = true;
    notifyListeners();

    _lessons = await _adminService.getLessons(token, chapterId) ?? [];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshLessons(String token) async {
    if (_selectedChapterId == null) {
      return;
    }

    await loadLessons(token, _selectedChapterId!);
  }

  Future<bool> addLesson(String token, Map<String, dynamic> data) async {
    final success = await _adminService.createLesson(token, data);

    if (success) {
      await loadLessons(token, data['chapter_id']);
    }

    return success;
  }

  Future<bool> editLesson(
    String token,
    int lessonId,
    Map<String, dynamic> data,
  ) async {
    final success = await _adminService.updateLesson(token, lessonId, data);

    if (success) {
      await loadLessons(token, data['chapter_id']);
    }

    return success;
  }

  Future<bool> removeLesson(String token, int lessonId, int chapterId) async {
    final success = await _adminService.deleteLesson(token, lessonId);

    if (success) {
      await loadLessons(token, chapterId);
    }

    return success;
  }
}
