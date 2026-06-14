import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../providers/curriculum_provider.dart';
import '../models/grade_model.dart';
import '../models/chapter_model.dart';
import 'curriculum_detail_screen.dart';

class CurriculumScreen extends StatefulWidget {
  const CurriculumScreen({super.key});

  @override
  State<CurriculumScreen> createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends State<CurriculumScreen> {
  final TextEditingController _searchController = TextEditingController();

  int? selectedGradeId;

  List<ChapterModel> filteredChapters = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurriculumProvider>().loadGrades();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterChapter(String keyword, List<ChapterModel> chapters) {
    setState(() {
      if (keyword.trim().isEmpty) {
        filteredChapters = chapters;
      } else {
        filteredChapters = chapters
            .where((e) => e.title.toLowerCase().contains(keyword.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CurriculumProvider>();

    final grades = provider.grades;
    final chapters = provider.chapters;

    if (filteredChapters.isEmpty && chapters.isNotEmpty) {
      filteredChapters = chapters;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      body: Column(
        children: [
          _buildHeader(),

          _buildSearchBox(chapters),

          _buildGradeSelector(grades),

          Expanded(child: _buildBody(provider)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),

      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
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
            "Đại số THCS",

            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox(List<ChapterModel> chapters) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),

      child: TextField(
        controller: _searchController,

        onChanged: (value) {
          _filterChapter(value, chapters);
        },

        decoration: InputDecoration(
          hintText: "Tìm chương học...",

          prefixIcon: const Icon(Icons.search, color: AppColors.primary),

          filled: true,

          fillColor: AppColors.primary.withOpacity(0.05),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),

            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildGradeSelector(List<GradeModel> grades) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),

      height: 45,

      child: ListView.builder(
        scrollDirection: Axis.horizontal,

        padding: const EdgeInsets.symmetric(horizontal: 16),

        itemCount: grades.length,

        itemBuilder: (context, index) {
          final grade = grades[index];

          final isSelected = selectedGradeId == grade.id;

          return Padding(
            padding: const EdgeInsets.only(right: 10),

            child: GestureDetector(
              onTap: () async {
                setState(() {
                  selectedGradeId = grade.id;
                });

                await context.read<CurriculumProvider>().loadChapters(grade.id);

                setState(() {
                  filteredChapters = context
                      .read<CurriculumProvider>()
                      .chapters;
                });
              },

              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),

                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 10,
                ),

                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.1),

                  borderRadius: BorderRadius.circular(15),
                ),

                child: Center(
                  child: Text(
                    grade.name,

                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.primary,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(CurriculumProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(child: Text(provider.error!));
    }

    if (filteredChapters.isEmpty) {
      return const Center(child: Text("Chưa có dữ liệu"));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

      itemCount: filteredChapters.length,

      itemBuilder: (context, index) {
        return _buildChapterCard(filteredChapters[index]);
      },
    );
  }

  Widget _buildChapterCard(
      ChapterModel chapter,
      ) {
    final provider =
    context.watch<CurriculumProvider>();

    final lessons =
        provider.lessonsByChapter[
        chapter.id] ??
            [];

    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),

      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(20),
      ),

      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor:
          AppColors.primary
              .withOpacity(0.1),

          child: Text(
            chapter.chapterNumber
                .toString(),
          ),
        ),

        title: Text(
          chapter.title,
          style: const TextStyle(
            fontWeight:
            FontWeight.bold,
            fontSize: 16,
          ),
        ),

        subtitle: Text(
          "Chương ${chapter.chapterNumber}",
        ),

        onExpansionChanged:
            (expanded) async {

          if (expanded &&
              !provider
                  .lessonsByChapter
                  .containsKey(
                chapter.id,
              )) {

            await provider.loadLessons(
              chapter.id,
            );
          }
        },

        children: lessons.map((lesson) {
          return ListTile(
            leading: const Icon(
              Icons.menu_book,
              color:
              AppColors.primary,
            ),

            title: Text(
              lesson.title,
            ),

            subtitle: Text(
              "Bài ${lesson.lessonNumber}",
            ),

            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 14,
            ),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CurriculumDetailScreen(
                        lessonId:
                        lesson.id,
                      ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
