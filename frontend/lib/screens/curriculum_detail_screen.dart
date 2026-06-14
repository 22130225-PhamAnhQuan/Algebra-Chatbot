import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/curriculum_provider.dart';
import '../models/lesson_detail_model.dart';
import '../core/theme/app_theme.dart';

class CurriculumDetailScreen extends StatefulWidget {
  final int lessonId;

  const CurriculumDetailScreen({super.key, required this.lessonId});

  @override
  State<CurriculumDetailScreen> createState() => _CurriculumDetailScreenState();
}

class _CurriculumDetailScreenState extends State<CurriculumDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurriculumProvider>().loadLessonDetail(widget.lessonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CurriculumProvider>();

    final LessonDetailModel? lesson = provider.lessonDetail;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      appBar: AppBar(title: const Text("Chi tiết bài học"), centerTitle: true),

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : lesson == null
          ? const Center(child: Text("Không có dữ liệu"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          "Bài ${lesson.lessonNumber}",

                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          lesson.title,

                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Lý thuyết",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey.shade100,
                    ),

                    child: Text(
                      lesson.theory ?? "",
                      style: const TextStyle(fontSize: 16, height: 1.6),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Ví dụ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.green.shade50,
                    ),

                    child: Text(
                      lesson.example ?? "",

                      style: const TextStyle(fontSize: 16, height: 1.6),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
