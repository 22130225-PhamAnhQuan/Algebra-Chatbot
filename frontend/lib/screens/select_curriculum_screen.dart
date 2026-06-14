import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../providers/curriculum_provider.dart';
import '../providers/solver_provider.dart';
import 'solve_problem_screen.dart';

class SelectCurriculumScreen extends StatefulWidget {
  const SelectCurriculumScreen({super.key});

  @override
  State<SelectCurriculumScreen> createState() => _SelectCurriculumScreenState();
}

class _SelectCurriculumScreenState extends State<SelectCurriculumScreen> {
  int? _selectedGradeId;
  int? _selectedChapterId;
  int? _selectedLessonId;

  int _step = 0; // 0: grade, 1: chapter, 2: lesson

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurriculumProvider>().loadGrades();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        if (_step > 0) {
          setState(() {
            _step--;
            if (_step == 0) {
              _selectedGradeId = null;
              context .read<CurriculumProvider>() .clearChapters();
            } else if (_step == 1) {
              _selectedChapterId = null;
              context .read<CurriculumProvider>() .clearLessons();
            }
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            _getAppBarTitle(),
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
        ),
        body: Consumer<CurriculumProvider>(
          builder: (context, curriculumProvider, _) {
            return Column(
              children: [
                _buildProgressBar(),
                Expanded(
                  child: _buildContent(curriculumProvider),
                ),
                if (_step == 2)
                  _buildContinueButton(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _buildProgressStep(0, "Lớp"),
          _buildProgressConnector(0),
          _buildProgressStep(1, "Chương"),
          _buildProgressConnector(1),
          _buildProgressStep(2, "Bài học"),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int stepNum, String label) {
    final isActive = _step >= stepNum;
    final isCurrent = _step == stepNum;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "${stepNum + 1}",
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isCurrent ? AppColors.primary : Colors.grey,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressConnector(int index) {
    final isActive = _step > index;

    return Container(
      height: 2,
      width: 20,
      color: isActive ? AppColors.primary : Colors.grey[300],
    );
  }

  Widget _buildContent(CurriculumProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 50),
            const SizedBox(height: 16),
            Text(provider.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                provider.loadGrades();
              },
              child: const Text("Thử lại"),
            ),
          ],
        ),
      );
    }

    if (_step == 0) {
      return _buildGradeSelection(provider);
    } else if (_step == 1) {
      return _buildChapterSelection(provider);
    } else {
      return _buildLessonSelection(provider);
    }
  }

  Widget _buildGradeSelection(CurriculumProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          "Chọn lớp học",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 20),
        ...provider.grades.map((grade) {
          return _buildSelectionCard(
            title: grade.name,
            isSelected: _selectedGradeId == grade.id,
            onTap: () async {
              setState(() {
                _selectedGradeId = grade.id;
                _step = 1;
              });
              await provider.loadChapters( grade.id, ); },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildChapterSelection(CurriculumProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          "Chọn chương",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 20),
        ...provider.chapters.map((chapter) {
          return _buildSelectionCard(
            title: "Chương ${chapter.chapterNumber}: ${chapter.title}",
            isSelected: _selectedChapterId == chapter.id,
              onTap: () async {

            setState(() {
              _selectedChapterId = chapter.id;
              _step = 2;
            });

            await provider.loadLessons(
              chapter.id,
            );
          },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildLessonSelection(
      CurriculumProvider provider,
      ) {

    final lessons =
        provider.lessonsByChapter[
        _selectedChapterId] ??
            [];

    return ListView(
      padding: const EdgeInsets.all(24),

      children: [
        Text(
          "Chọn bài học",
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
            fontWeight:
            FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        ...lessons.map((lesson) {
          return _buildSelectionCard(
            title:
            "Bài ${lesson.lessonNumber}: ${lesson.title}",

            isSelected:
            _selectedLessonId ==
                lesson.id,

            onTap: () {
              setState(() {
                _selectedLessonId =
                    lesson.id;
              });
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
            color: isSelected
                ? AppColors.primary.withOpacity(0.05)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isSelected ? AppColors.primary : null,
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: _selectedLessonId == null ? null : () {
            final solverProvider = context.read<SolverProvider>();
            solverProvider.setGrade( _selectedGradeId!, );
            solverProvider.setChapter( _selectedChapterId!, );
            solverProvider.setLesson( _selectedLessonId!, );
            Navigator.pushReplacement( context,
              MaterialPageRoute( builder: (_) => const SolveProblemScreen(),
              ),);
            },
          child: const Text(
            "Tiếp tục",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    if (_step == 0) {
      return "Chọn lớp học";
    } else if (_step == 1) {
      return "Chọn chương";
    } else {
      return "Chọn bài học";
    }
  }
}
