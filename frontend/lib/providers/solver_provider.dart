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

  Future<SolutionModel?> solve({
    String? text,
    File? image,
    required String token,
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