import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';
import '../models/history_model.dart';
import '../services/history_service.dart';

class HistoryProvider extends ChangeNotifier {
  List<HistoryItem> _historyList = [];
  bool _isLoading = false;
  String _errorMessage = "";

  List<HistoryItem> get historyList => _historyList;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Hàm lấy danh sách lịch sử từ Backend
  Future<void> fetchHistory() async {
    _isLoading = true;
    _errorMessage = "";
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? "";

      // Gọi thông qua Service vừa viết
      final data = await HistoryApiService.fetchHistory(token);

      _historyList = data.map((json) => HistoryItem.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Hàm xóa một mục lịch sử
  Future<void> deleteHistory(int historyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? "";

      // Gọi API xóa từ Service
      final success = await HistoryApiService.deleteHistoryItem(token, historyId);

      if (success) {
        // Xóa item khỏi danh sách cục bộ để cập nhật UI ngay lập tức
        _historyList.removeWhere((item) => item.id == historyId);
        notifyListeners(); // Thông báo cho UI vẽ lại
      } else {
        _errorMessage = "Không thể xóa mục này.";
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Lỗi kết nối khi xóa.";
      notifyListeners();
    }
  }
}