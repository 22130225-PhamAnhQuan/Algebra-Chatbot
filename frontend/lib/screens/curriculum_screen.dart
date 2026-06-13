import 'package:provider/provider.dart';

import '../providers/curriculum_provider.dart';
import '../models/chapter_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

class CurriculumScreen extends StatefulWidget {
  const CurriculumScreen({super.key});

  @override
  State<CurriculumScreen> createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends State<CurriculumScreen> {
  int? _selectedGradeId;
  int? _selectedChapterId;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read().loadGrades();
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Giải phóng bộ nhớ
    super.dispose();
  }

  // Thêm tham số forceRefresh để hỗ trợ vuốt xuống tải lại
  Future<void> fetchFormulas({bool forceRefresh = false}) async {
    if (!mounted) return;

    // Nếu KHÔNG bắt buộc tải mới và dữ liệu lớp này đã có trong Cache -> Dùng luôn
    if (!forceRefresh && _cachedData.containsKey(_selectedGrade) && _cachedData[_selectedGrade]!.isNotEmpty) {
      setState(() {
        allFormulas = _cachedData[_selectedGrade]!;
        filteredFormulas = allFormulas;
        isLoading = false;
        error = '';
        _searchController.clear();
      });
      return;
    }

    // Nếu chưa có cache hoặc đang forceRefresh, tiến hành gọi API
    setState(() {
      isLoading = true;
      error = '';
      if (!forceRefresh) _searchController.clear();
    });

    try {
      final data = await FormulaService.getByGrade(_selectedGrade);
      if (mounted) {
        setState(() {
          _cachedData[_selectedGrade] = data; // Lưu hoặc cập nhật vào cache
          allFormulas = data;

          // Giữ lại kết quả tìm kiếm nếu đang pull-to-refresh lúc có chữ
          if (_searchController.text.isNotEmpty) {
            _filterFormulas(_searchController.text);
          } else {
            filteredFormulas = data;
          }

          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Không kết nối được với máy chủ Backend';
          isLoading = false;
          // Xóa danh sách nếu có lỗi để tránh hiển thị sai
          allFormulas = [];
          filteredFormulas = [];
        });
      }
    }
  }

  // Hàm xử lý tìm kiếm (Null-safe)
  void _filterFormulas(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        filteredFormulas = allFormulas;
      } else {
        filteredFormulas = allFormulas
            .where((f) =>
        (f.title.toLowerCase().contains(query.toLowerCase())) ||
            (f.formula.toLowerCase().contains(query.toLowerCase())))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBox(),
          _buildGradeSelector(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Giáo trình",
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Đại số lớp $_selectedGrade",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  // ================= SEARCH BOX =================
  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: TextField(
        controller: _searchController,
        onChanged: _filterFormulas,
        decoration: InputDecoration(
          hintText: "Tìm công thức...",
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          filled: true,
          fillColor: AppColors.primary.withOpacity(0.05),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  // ================= SELECT GRADE =================
  Widget _buildGradeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [6, 7, 8, 9].map((grade) {
          final isSelected = _selectedGrade == grade;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                // Chỉ xử lý nếu chọn tab khác với tab hiện tại
                if (_selectedGrade != grade) {
                  setState(() => _selectedGrade = grade);
                  fetchFormulas();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    "Lớp $grade",
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================= BODY =================
  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 10),
            Text(error),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => fetchFormulas(forceRefresh: true),
              child: const Text("Thử lại"),
            )
          ],
        ),
      );
    }

    if (filteredFormulas.isEmpty) {
      return const Center(child: Text("Không tìm thấy kết quả"));
    }

    return RefreshIndicator(
      // Gọi tải lại và ép buộc lấy dữ liệu mới nhất (bỏ qua cache)
      onRefresh: () => fetchFormulas(forceRefresh: true),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: filteredFormulas.length,
        itemBuilder: (ctx, i) => _buildFormulaCard(filteredFormulas[i]),
      ),
    );
  }

  // ================= CARD =================
  Widget _buildFormulaCard(Formula item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FormulaDetailScreen(data: item)),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "Q",
                      style: GoogleFonts.dmSans(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey[50]
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.formula,
                  style: GoogleFonts.firaCode(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}