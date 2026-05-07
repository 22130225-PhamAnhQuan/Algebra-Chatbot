import 'dart:io';
import 'package:flutter/material.dart';
import '../models/solution_model.dart';
import '../services/solver_service.dart';

class SolverProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<SolutionModel> _history = [];
  List<SolutionModel> get history => _history;

  // Hàm xử lý chính: Chấp nhận cả Text hoặc File
  Future<SolutionModel?> solve({
    String? text,
    File? image,
    required String token,
  }) async {
    _isLoading = true;
    notifyListeners(); // Thông báo cho UI hiển thị Loading

    try {
      final result = await SolverService.solveProblem(
        problemText: text,
        imageFile: image,
        token: token,
      );

      _history.add(result);
      return result;
    } catch (e) {
      rethrow; // Đẩy lỗi ra để Screen hiển thị SnackBar/Dialog
    } finally {
      _isLoading = false;
      notifyListeners(); // Tắt Loading dù thành công hay thất bại
    }
  }
}