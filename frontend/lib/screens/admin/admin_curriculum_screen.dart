import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';

class AdminCurriculumScreen extends StatefulWidget {
  final String token;

  const AdminCurriculumScreen({Key? key, required this.token})
    : super(key: key);

  @override
  State<AdminCurriculumScreen> createState() => _AdminCurriculumScreenState();
}

class _AdminCurriculumScreenState extends State<AdminCurriculumScreen> {
  int? _selectedGradeId;
  int? _selectedChapterId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadGrades(widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: Column(
        children: [
          _buildHeader(),

          _buildGradeSelector(provider),

          if (_selectedGradeId != null) _buildChapterSelector(provider),

          Expanded(child: _buildBody(provider)),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {

          if(_selectedChapterId == null){

            ScaffoldMessenger.of(context)
                .showSnackBar(
              const SnackBar(
                content: Text(
                  "Hãy chọn chương trước",
                ),
              ),
            );

            return;
          }

          _showLessonForm();
        },
        backgroundColor: const Color(0xFF4F46E5),

        icon: const Icon(Icons.add, color: Colors.white),

        label: Text(
          "Thêm bài học",
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.only(top: 56, left: 20, right: 20, bottom: 28),

      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF4F46E5)],
        ),

        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),

          bottomRight: Radius.circular(32),
        ),
      ),

      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },

            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                "Quản lý Giáo trình",

                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                "Kết nối tri thức",

                style: GoogleFonts.dmSans(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGradeSelector(AdminProvider provider) {
    return Container(
      height: 60,

      margin: const EdgeInsets.only(top: 16),

      child: ListView.builder(
        scrollDirection: Axis.horizontal,

        padding: const EdgeInsets.symmetric(horizontal: 16),

        itemCount: provider.grades.length,

        itemBuilder: (context, index) {
          final grade = provider.grades[index];

          final selected = _selectedGradeId == grade["id"];

          return Padding(
            padding: const EdgeInsets.only(right: 8),

            child: ChoiceChip(
              label: Text(grade["name"]),

              selected: selected,

              onSelected: (_) async {
                setState(() {
                  _selectedGradeId = grade["id"];

                  _selectedChapterId = null;
                });

                await provider.loadChapters(widget.token, grade["id"]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildChapterSelector(AdminProvider provider) {
    return Container(
      height: 60,

      margin: const EdgeInsets.only(top: 8),

      child: ListView.builder(
        scrollDirection: Axis.horizontal,

        padding: const EdgeInsets.symmetric(horizontal: 16),

        itemCount: provider.chapters.length,

        itemBuilder: (context, index) {
          final chapter = provider.chapters[index];

          final selected = _selectedChapterId == chapter["id"];

          return Padding(
            padding: const EdgeInsets.only(right: 8),

            child: ChoiceChip(
              label: Text(chapter["title"]),

              selected: selected,

              onSelected: (_) async {
                setState(() {
                  _selectedChapterId = chapter["id"];
                });

                await provider.loadLessons(widget.token, chapter["id"]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(AdminProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.lessons.isEmpty) {
      return Center(
        child: Text(
          "Chưa có bài học",

          style: GoogleFonts.dmSans(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),

      itemCount: provider.lessons.length,

      itemBuilder: (context, index) {
        final lesson = provider.lessons[index];

        return _buildLessonCard(lesson, provider);
      },
    );
  }

  Widget _buildLessonCard(dynamic lesson, AdminProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Bài ${lesson["lesson_number"]}",
                style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () {
                      _showLessonForm(
                        lesson: lesson,
                      );
                    },
                  ),
                  IconButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Xóa bài học"),
                          content: Text(
                            "Bạn có chắc muốn xóa '${lesson["title"]}' ?",
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              child: const Text("Xóa"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                              child: const Text("Hủy"),
                            ),

                          ],
                        ),
                      );

                      if (confirm == true) {
                        await provider.removeLesson(
                          widget.token,
                          lesson["id"],
                          lesson["chapter_id"],
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Đã xóa bài học"),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            lesson["title"] ?? "",
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            lesson["theory"] ?? "",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showLessonForm({
    Map<String,dynamic>? lesson,
  }) { final lessonNumberController =
  TextEditingController(
    text: lesson?["lesson_number"]?.toString() ?? "",
  );

  final titleController =
  TextEditingController(
    text: lesson?["title"] ?? "",
  );

  final theoryController =
  TextEditingController(
    text: lesson?["theory"] ?? "",
  );

  final formulaController =
  TextEditingController(
    text: lesson?["formula"] ?? "",
  );

  final exampleController =
  TextEditingController(
    text: lesson?["example"] ?? "",
  );

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) {

      return Padding(
        padding: EdgeInsets.only(
          bottom:
          MediaQuery.of(context)
              .viewInsets
              .bottom,
        ),

        child: StatefulBuilder(
          builder: (context,setModalState){

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,

                  children: [

                    Text(
                      lesson == null
                          ? "Thêm bài học"
                          : "Chỉnh sửa bài học",
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height:20),

                    TextField(
                      controller:
                      lessonNumberController,
                      keyboardType:
                      TextInputType.number,
                      decoration:
                      const InputDecoration(
                        labelText:
                        "Số bài",
                      ),
                    ),

                    const SizedBox(height:12),

                    TextField(
                      controller:
                      titleController,
                      decoration:
                      const InputDecoration(
                        labelText:
                        "Tên bài học",
                      ),
                    ),

                    const SizedBox(height:12),

                    TextField(
                      controller:
                      theoryController,
                      maxLines: 5,
                      decoration:
                      const InputDecoration(
                        labelText:
                        "Lý thuyết",
                      ),
                    ),

                    const SizedBox(height:12),

                    TextField(
                      controller:
                      formulaController,
                      maxLines: 3,
                      decoration:
                      const InputDecoration(
                        labelText:
                        "Công thức",
                      ),
                    ),

                    const SizedBox(height:12),

                    TextField(
                      controller:
                      exampleController,
                      maxLines: 5,
                      decoration:
                      const InputDecoration(
                        labelText:
                        "Ví dụ",
                      ),
                    ),

                    const SizedBox(height:20),

                    ElevatedButton(
                      onPressed: () async {

                        final data = {

                          "chapter_id":
                          _selectedChapterId,

                          "lesson_number":
                          int.parse(
                            lessonNumberController.text,
                          ),

                          "title":
                          titleController.text,

                          "theory":
                          theoryController.text,

                          "formula":
                          formulaController.text,

                          "example":
                          exampleController.text,
                        };

                        bool success;

                        if(lesson == null){

                          success =
                          await context
                              .read<
                              AdminProvider>()
                              .addLesson(
                            widget.token,
                            data,
                          );

                        } else {

                          success =
                          await context
                              .read<
                              AdminProvider>()
                              .editLesson(
                            widget.token,
                            lesson["id"],
                            data,
                          );
                        }

                        if(success){

                          Navigator.pop(
                            context,
                          );

                          ScaffoldMessenger
                              .of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                lesson == null
                                    ? "Đã thêm bài học"
                                    : "Đã cập nhật bài học",
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        lesson == null
                            ? "Thêm"
                            : "Cập nhật",
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
  }
}
