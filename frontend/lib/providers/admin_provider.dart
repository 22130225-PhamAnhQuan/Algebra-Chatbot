import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  Map<String, dynamic>? _stats;
  List<dynamic> _users = [];
  List<dynamic> _aiLogs = [];
  List<dynamic> _histories = [];
  List<dynamic> _formulas = [];
  bool _isLoading = false;

  // Getters công khai để UI tiêu thụ
  Map<String, dynamic>? get stats => _stats;
  List<dynamic> get users => _users;
  List<dynamic> get aiLogs => _aiLogs;
  List<dynamic> get histories => _histories;
  List<dynamic> get formulas => _formulas;
  bool get isLoading => _isLoading;

  // ==========================================
  // 1. TẢI ĐỒNG LOẠT DỮ LIỆU (READ ALL)
  // ==========================================
  Future<void> fetchAllAdminData(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Gọi đồng thời hoặc tuần tự các API từ Service
      final statsData = await _adminService.getDashboardStats(token);
      if (statsData != null && statsData['success'] == true) {
        _stats = statsData['data'];
      }

      _users = await _adminService.getAllUsers(token) ?? [];
      _aiLogs = await _adminService.getAILogs(token) ?? [];
      _histories = await _adminService.getAllHistories(token) ?? [];
      _formulas = await _adminService.getAllFormulas(token) ?? [];
    } catch (e) {
      print("Lỗi fetchAllAdminData: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 2. QUẢN LÝ TÀI KHOẢN (USER)
  // ==========================================
  Future<bool> toggleUser(String token, int userId, int index) async {
    final success = await _adminService.toggleUserStatus(token, userId);
    if (success) {
      // Đảo ngược trạng thái hoạt động cục bộ để UI cập nhật ngay lập tức
      _users[index]['is_active'] = !_users[index]['is_active'];
      notifyListeners();
      return true;
    }
    return false;
  }

  // ==========================================
  // 3. QUẢN LÝ GIÁO TRÌNH / CÔNG THỨC (FORMULA CRUD)
  // ==========================================

  // Thêm mới công thức toán
  Future<bool> addFormula(String token, Map<String, dynamic> formulaData) async {
    final success = await _adminService.createFormula(token, formulaData);
    if (success) {
      // Tải lại danh sách công thức để cập nhật dữ liệu mới nhất
      _formulas = await _adminService.getAllFormulas(token) ?? [];

      // Cập nhật lại số lượng trong ô thống kê Dashboard (nếu có)
      if (_stats != null && _stats!['overview'] != null) {
        _stats!['overview']['total_formulas_in_curriculum'] =
            (_stats!['overview']['total_formulas_in_curriculum'] ?? 0) + 1;
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  // Chỉnh sửa công thức toán
  Future<bool> editFormula(String token, int formulaId, int index, Map<String, dynamic> formulaData) async {
    final success = await _adminService.updateFormula(token, formulaId, formulaData);
    if (success) {
      // Cập nhật trực tiếp vào item trong mảng State cục bộ để tránh re-fetch lãng phí dữ liệu
      _formulas[index]['grade'] = formulaData['grade'];
      _formulas[index]['title'] = formulaData['title'];
      _formulas[index]['formula'] = formulaData['formula'];
      _formulas[index]['explanation'] = formulaData['explanation'];
      _formulas[index]['example'] = formulaData['example'];
      _formulas[index]['category'] = formulaData['category'];
      notifyListeners();
      return true;
    }
    return false;
  }

  // Xóa công thức toán khỏi giáo trình
  Future<bool> removeFormula(String token, int formulaId, int index) async {
    final success = await _adminService.deleteFormula(token, formulaId);
    if (success) {
      // Xóa phần tử khỏi danh sách cục bộ ngay lập tức
      _formulas.removeAt(index);

      // Giảm số lượng trong ô thống kê Dashboard
      if (_stats != null && _stats!['overview'] != null) {
        _stats!['overview']['total_formulas_in_curriculum'] =
            (_stats!['overview']['total_formulas_in_curriculum'] ?? 0) - 1;
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  // Hàm tải riêng danh sách công thức khi cần lọc theo Khối lớp (Toán 6 -> Toán 9)
  Future<void> filterFormulasByGrade(String token, int? grade) async {
    _isLoading = true;
    notifyListeners();
    _formulas = await _adminService.getAllFormulas(token, grade: grade) ?? [];
    _isLoading = false;
    notifyListeners();
  }
}