import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/core/app_them_maneger/app_colors.dart';
import 'package:notes_app/core/modules/lay_out_view_feature/presentation/maneger/notes_bloc.dart';
import 'package:notes_app/core/modules/lay_out_view_feature/presentation/maneger/notes_event.dart';

import '../../domain/entity/note_entity.dart';

class NotesScreen extends StatefulWidget {
  final Map<String, dynamic>? existingNote;
  final String? imagePath;

  const NotesScreen({super.key, this.existingNote, this.imagePath});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _checklistItems = [];

  @override
  void initState() {
    super.initState();

    if (widget.existingNote != null) {
      _titleController.text = widget.existingNote!['title'] ?? '';

      // قراءة الـ content وتقسيمه لعناصر قائمة مع الحفاظ على حالة المربع القديمة [x] أو [ ]
      if (widget.existingNote!['content'] != null &&
          widget.existingNote!['content'].toString().isNotEmpty) {
        final String rawContent = widget.existingNote!['content'];
        final lines = rawContent.split('\n');

        for (var line in lines) {
          final trimmed = line.trim();
          if (trimmed.startsWith('[x]') || trimmed.startsWith('[X]')) {
            _checklistItems.add({
              'title': trimmed.substring(3).trim(),
              'isDone': true,
            });
          } else if (trimmed.startsWith('[ ]')) {
            _checklistItems.add({
              'title': trimmed.substring(3).trim(),
              'isDone': false,
            });
          } else if (trimmed.isNotEmpty) {
            // لو سطر نصي عادي قديم مش معمول له مربعات
            _checklistItems.add({
              'title': trimmed,
              'isDone': false,
            });
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _itemController.dispose();
    super.dispose();
  }

  // دالة لفتح الصورة بحجم الشاشة والقدرة على عمل Zoom
  void _showFullImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8AC53E),
              onPrimary: Colors.black,
              surface: AppColors.cardColor,
              onSurface: AppColors.primaryText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveAndPop() {
    final titleText = _titleController.text.trim();
    final itemInputText = _itemController.text.trim();

    // لو المستخدم كتب حاجة في حقل الإضافة وما ضغطش على علامة +، نضيفها تلقائياً قبل الحفظ
    if (itemInputText.isNotEmpty) {
      _checklistItems.add({
        'title': itemInputText,
        'isDone': false,
      });
      _itemController.clear();
    }

    if (titleText.isNotEmpty || _checklistItems.isNotEmpty) {
      final isUpdating = widget.existingNote != null && widget.existingNote!['id'] != null;
      final String noteId = isUpdating
          ? widget.existingNote!['id']
          : DateTime.now().millisecondsSinceEpoch.toString();

      // دمج العناصر مع علامات المربعات [x] و [ ] عشان الهوم والـ NotesScreen يقروها صح
      String combinedContent = "";
      if (_checklistItems.isNotEmpty) {
        combinedContent = _checklistItems
            .map((item) => "${item['isDone'] == true ? '[x]' : '[ ]'} ${item['title']}")
            .join('\n');
      } else {
        combinedContent = itemInputText;
      }

      final noteEntity = NoteEntity(
        id: noteId,
        title: titleText.isEmpty ? 'New Note' : titleText,
        content: combinedContent,
        date: DateFormat('d MMM').format(_selectedDate),
        imagePath: widget.imagePath ?? (isUpdating ? widget.existingNote!['imagePath'] : null),
      );

      if (isUpdating) {
        BlocProvider.of<NotesBloc>(context).add(
          UpdateNoteEvent(noteEntity),
        );
      } else {
        BlocProvider.of<NotesBloc>(context).add(
          AddNoteEvent(noteEntity),
        );
      }

      Navigator.pop(context);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const SizedBox(
                      width: 30,
                      height: 30,
                      child: Icon(
                        Icons.close,
                        color: AppColors.primaryText,
                        size: 26,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _saveAndPop,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8AC53E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      const SizedBox(
                        width: 30,
                        height: 30,
                        child: Icon(
                          Icons.person_add_outlined,
                          color: AppColors.secondaryText,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const SizedBox(
                        width: 30,
                        height: 30,
                        child: Icon(
                          Icons.home_outlined,
                          color: AppColors.secondaryText,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const SizedBox(
                        width: 30,
                        height: 30,
                        child: Icon(
                          Icons.more_vert,
                          color: AppColors.secondaryText,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    GestureDetector(
                      onTap: _pickDate,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('d MMM, yyyy').format(_selectedDate),
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.secondaryText,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: _titleController,
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Note Title...',
                        hintStyle: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 24,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 15),

                    if (widget.imagePath != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: GestureDetector(
                          onTap: () => _showFullImage(context, widget.imagePath!),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(widget.imagePath!),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                    ],

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _checklistItems.length,
                      itemBuilder: (context, index) {
                        final item = _checklistItems[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 30,
                                height: 30,
                                child: Checkbox(
                                  value: item['isDone'],
                                  onChanged: (val) {
                                    setState(() {
                                      item['isDone'] = val ?? false;
                                    });
                                  },
                                  activeColor: const Color(0xFF8AC53E),
                                  checkColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  side: const BorderSide(
                                    color: AppColors.secondaryText,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item['title'],
                                  style: TextStyle(
                                    color: item['isDone']
                                        ? AppColors.primaryText
                                        : AppColors.secondaryText,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: AppColors.secondaryText,
                                  size: 18,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _checklistItems.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _itemController,
                            style: const TextStyle(color: AppColors.primaryText),
                            decoration: const InputDecoration(
                              hintText: 'Type content or add item...',
                              hintStyle: TextStyle(color: AppColors.secondaryText),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                setState(() {
                                  _checklistItems.add({
                                    'title': value.trim(),
                                    'isDone': false,
                                  });
                                  _itemController.clear();
                                });
                              }
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (_itemController.text.trim().isNotEmpty) {
                              setState(() {
                                _checklistItems.add({
                                  'title': _itemController.text.trim(),
                                  'isDone': false,
                                });
                                _itemController.clear();
                              });
                            }
                          },
                          icon: const Icon(Icons.add, color: AppColors.greenButton),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}