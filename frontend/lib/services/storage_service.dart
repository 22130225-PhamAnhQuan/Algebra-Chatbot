// lib/services/storage_service.dart
//
// Lưu lịch sử chat vào SharedPreferences (local)
// Dùng cho offline history và khôi phục session
//
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const _kMessages  = 'chat_messages';
  static const _kHistory   = 'solve_history';
  static const _maxMessages = 100; // giới hạn lưu trữ

  final SharedPreferences _prefs;

  StorageService._(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }

  // ── Chat messages ──────────────────────────────────────────────

  Future<void> saveMessages(List<MessageModel> messages) async {
    final limited = messages.length > _maxMessages
        ? messages.sublist(messages.length - _maxMessages)
        : messages;
    final json = limited.map((m) => m.toJson()).toList();
    await _prefs.setString(_kMessages, jsonEncode(json));
  }

  List<MessageModel> loadMessages() {
    final raw = _prefs.getString(_kMessages);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((j) => MessageModel.fromJson(j)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clearMessages() async {
    await _prefs.remove(_kMessages);
  }

  // ── Solve history ──────────────────────────────────────────────

  Future<void> saveHistory(List<HistoryModel> history) async {
    final json = history.map((h) => h.toJson()).toList();
    await _prefs.setString(_kHistory, jsonEncode(json));
  }

  List<HistoryModel> loadHistory() {
    final raw = _prefs.getString(_kHistory);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((j) => HistoryModel.fromJson(j)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addHistory(HistoryModel item) async {
    final current = loadHistory();
    current.insert(0, item); // mới nhất ở đầu
    await saveHistory(current);
  }

  Future<void> deleteHistory(String id) async {
    final current = loadHistory()..removeWhere((h) => h.id == id);
    await saveHistory(current);
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_kHistory);
  }
}
