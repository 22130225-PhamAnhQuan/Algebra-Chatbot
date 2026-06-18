import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/history_model.dart';
import '../services/history_service.dart';

class HistoryProvider extends ChangeNotifier {
  List<HistoryItem> _historyList = [];
  bool _isLoading = false;
  String _errorMessage = "";

  Timer? _autoSyncTimer;

  List<HistoryItem> get historyList => List.unmodifiable(_historyList);
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchHistory({bool merge = false}) async {
    _isLoading = true;
    _errorMessage = "";
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? "";

      final data = await HistoryApiService.fetchHistory(token);

      if (data is List) {
        final List<HistoryItem> temp = [];

        for (var item in data) {
          try {
            temp.add(HistoryItem.fromJson(item));
          } catch (e) {
            debugPrint("Lỗi Parse Lịch sử (ID: ${item['id']}): $e");
          }
        }

        if (merge) {
          final Map<int, HistoryItem> map = {
            for (var item in _historyList) item.id: item
          };

          for (var item in temp) {
            map[item.id] = item;
          }

          _historyList = map.values.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        } else {
          _historyList = temp
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }
      }
    } catch (e) {
      _errorMessage = "Lỗi tải lịch sử: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startAutoSync() {
    _autoSyncTimer?.cancel();

    _autoSyncTimer = Timer.periodic(
      const Duration(seconds: 5),
          (timer) {
        fetchHistory(merge: true);
      },
    );
  }

  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
  }

  Future<void> deleteHistory(int historyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? "";

      final success =
      await HistoryApiService.deleteHistoryItem(token, historyId);

      if (success) {
        _historyList.removeWhere((e) => e.id == historyId);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Lỗi khi xóa: $e";
      notifyListeners();
    }
  }

  // OPTIMISTIC ADD
  void addLocalHistory(HistoryItem item) {
    _historyList.insert(0, item);
    notifyListeners();
  }

  // CLEAR
  void clearHistory() {
    _historyList = [];
    notifyListeners();
  }
}