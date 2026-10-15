import 'package:flutter/material.dart';
import 'package:notes_app/core/app_them_maneger/app_colors.dart';
import 'package:notes_app/core/modules/lay_out_view_feature/presentation/pages/notes_screen.dart';
import 'plus_tap_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. قائمة الملاحظات تبدأ فارغة تماماً كما طلبت
  List<Map<String, dynamic>> notesList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Helo\n'
                        'My Notes',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.tune, color: AppColors.primaryText),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const TextField(
                    style: TextStyle(color: AppColors.primaryText),
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.search,
                        color: AppColors.secondaryText,
                      ),
                      hintText: 'Search Here',
                      hintStyle: TextStyle(color: AppColors.secondaryText),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. عرض الكروت ديناميكياً أو إظهار رسالة لو القائمة فارغة
              Expanded(
                child: notesList.isEmpty
                    ? const Center(
                  child: Text(
                    'No notes yet.\nTap + to create one!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 16,
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: notesList.length,
                  itemBuilder: (context, index) {
                    final note = notesList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: GestureDetector(
                        // عند الضغط على الكارت نرسل النوتة الحالية لفتحها وتعديلها
                        onTap: () async {
                          final updatedNote = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotesScreen(existingNote: note),
                            ),
                          );
                          // لو تم التعديل والحفظ، نحدث الكارت في مكانه
                          if (updatedNote != null && updatedNote is Map<String, dynamic>) {
                            setState(() {
                              notesList[index] = updatedNote;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    note['date'] ?? '',
                                    style: const TextStyle(
                                      color: AppColors.secondaryText,
                                      fontSize: 15,
                                    ),
                                  ),
                                  // زر سلة المهملات للحذف
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        notesList.removeAt(index);
                                      });
                                    },
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: AppColors.secondaryText,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                note['title'] ?? '',
                                style: const TextStyle(
                                  color: AppColors.primaryText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // لو الكارت عبارة عن قائمة Checkboxes
                              if (note['isChecklist'] == true && note['items'] != null) ...[
                                Column(
                                  children: (note['items'] as List)
                                      .map((item) => _buildCheckBoxItem(
                                    item['title'],
                                    item['isDone'],
                                  ))
                                      .toList(),
                                ),
                              ],

                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  note['timeAgo'] ?? '',
                                  style: const TextStyle(
                                    color: AppColors.secondaryText,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 88,
        color: AppColors.bottomBar,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 90,
                height: 90,
                child: Icon(
                  Icons.menu,
                  color: AppColors.secondaryText,
                  size: 32,
                ),
              ),
            ),
            Positioned(
              top: -32,
              right: 6,
              child: GestureDetector(
                onTap: () async {
                  // فتح شاشة PlusTab ومنها للملاحظات، وعند الرجوع يتم التقاط النوتة الجديدة
                  final newNote = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PlusTabScreen(),
                    ),
                  );

                  // لو راجعين بداتا جديدة، نضيفها للقائمة فوراً
                  if (newNote != null && newNote is Map<String, dynamic>) {
                    setState(() {
                      notesList.add(newNote);
                    });
                  }
                },
                child: Container(
                  width: 80,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.add,
                        color: AppColors.primaryText,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckBoxItem(String title, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_box : Icons.check_box_outline_blank,
            size: 16,
            color: isDone ? const Color(0xFF8AC53E) : AppColors.secondaryText,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: isDone ? AppColors.primaryText : AppColors.secondaryText,
              fontSize: 13,
              decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}