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
  final String? filePath;
  final bool isPrivate;

  const NotesScreen({
    super.key,
    this.existingNote,
    this.imagePath,
    this.filePath,
    this.isPrivate = false,
  });

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  final List<Map<String, dynamic>> _checklistItems = [];
  bool _isNotePrivate = false;

  @override
  void initState() {
    super.initState();

    _isNotePrivate = widget.isPrivate || (widget.existingNote?['isPrivate'] ?? false);

    if (widget.existingNote != null) {
      _titleController.text = widget.existingNote!['title'] ?? '';
      _passwordController.text = widget.existingNote!['password'] ?? '';

      if (widget.existingNote!['reminderDateTime'] != null) {
        if (widget.existingNote!['reminderDateTime'] is DateTime) {
          final DateTime dt = widget.existingNote!['reminderDateTime'];
          _selectedDate = dt;
          _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
        } else if (widget.existingNote!['reminderDateTime'] is String) {
          final DateTime dt = DateTime.parse(widget.existingNote!['reminderDateTime']);
          _selectedDate = dt;
          _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
        }
      }

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
    _passwordController.dispose();
    super.dispose();
  }

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

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
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

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveAndPop() async {
    final titleText = _titleController.text.trim();
    final itemInputText = _itemController.text.trim();
    final passwordText = _passwordController.text.trim();

    if (_isNotePrivate && passwordText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a password for this private note.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

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

      String combinedContent = "";
      if (_checklistItems.isNotEmpty) {
        combinedContent = _checklistItems
            .map((item) => "${item['isDone'] == true ? '[x]' : '[ ]'} ${item['title']}")
            .join('\n');
      } else {
        combinedContent = itemInputText;
      }

      DateTime? reminderDateTime;
      if (_selectedTime != null) {
        reminderDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
      }

      final noteEntity = NoteEntity(
        id: noteId,
        title: titleText.isEmpty ? 'New Note' : titleText,
        content: combinedContent,
        date: DateFormat('d MMM').format(_selectedDate),
        imagePath: widget.imagePath ?? (isUpdating ? widget.existingNote!['imagePath'] : null),
        filePath: widget.filePath ?? (isUpdating ? widget.existingNote!['filePath'] : null),
        reminderDateTime: reminderDateTime,
        isPrivate: _isNotePrivate,
        password: _isNotePrivate ? passwordText : null,
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
    final effectiveImagePath =
        widget.imagePath ?? widget.existingNote?['imagePath'];
    final effectiveFilePath =
        widget.filePath ?? widget.existingNote?['filePath'];

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
                  GestureDetector(
                    onTap: _saveAndPop,
                    child: Container(
                      width: 55,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8AC53E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
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
                    Row(
                      children: [
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
                        const SizedBox(width: 15),
                        GestureDetector(
                          onTap: _pickTime,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _selectedTime == null
                                    ? Icons.notifications_none
                                    : Icons.notifications_active,
                                color: _selectedTime == null
                                    ? AppColors.secondaryText
                                    : const Color(0xFF8AC53E),
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _selectedTime == null
                                    ? 'Set Alarm'
                                    : _selectedTime!.format(context),
                                style: TextStyle(
                                  color: _selectedTime == null
                                      ? AppColors.secondaryText
                                      : const Color(0xFF8AC53E),
                                  fontSize: 14,
                                  fontWeight: _selectedTime == null
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    if (_isNotePrivate) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF8AC53E)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock, color: Color(0xFF8AC53E), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _passwordController,
                                obscureText: true,
                                style: const TextStyle(color: AppColors.primaryText),
                                decoration: const InputDecoration(
                                  hintText: 'Enter Password for Private Note...',
                                  hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 14),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
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
                    if (effectiveImagePath != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: GestureDetector(
                          onTap: () => _showFullImage(context, effectiveImagePath),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(effectiveImagePath),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (effectiveFilePath != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.insert_drive_file,
                                color: Color(0xFF8AC53E),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  effectiveFilePath.split('/').last,
                                  style: const TextStyle(
                                    color: AppColors.primaryText,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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