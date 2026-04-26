import 'package:flutter/material.dart';
import '../models/formula_model.dart';
import '../services/formula_service.dart';

class FormulaProvider extends ChangeNotifier {
  bool isLoading = false;
  String errorMessage = "";

  final Map<int, List<Formula>> _cachedFormulas = {};

  List<Formula> searchResults = [];

  Future<void> fetchFormulasByGrade(int grade) async {
    // Nếu đã tải lớp này rồi thì lấy từ Cache ra dùng luôn, không gọi API nữa
    if (_cachedFormulas.containsKey(grade) && _cachedFormulas[grade]!.isNotEmpty) {
      return;
    }

    isLoading = true;
    errorMessage = "";
    notifyListeners();

    try {
      final data = await FormulaService.getByGrade(grade);
      _cachedFormulas[grade] = data; // Lưu vào Cache
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Hàm để UI lấy dữ liệu ra hiển thị
  List<Formula> getFormulasForGrade(int grade) {
    return _cachedFormulas[grade] ?? [];
  }

  // 2. Tìm kiếm công thức (Không cache vì từ khóa đổi liên tục)
  Future<void> searchFormulas(String keyword) async {
    if (keyword.trim().isEmpty) {
      searchResults = [];
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = "";
    notifyListeners();

    try {
      searchResults = await FormulaService.searchFormulas(keyword);
    } catch (e) {
      errorMessage = "Lỗi tìm kiếm. Vui lòng thử lại.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}