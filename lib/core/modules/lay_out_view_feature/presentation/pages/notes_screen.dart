import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/core/app_them_maneger/app_colors.dart';

class NotesScreen extends StatefulWidget {
  final Map<String, dynamic>? existingNote;

  const NotesScreen({super.key, this.existingNote});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  // controllers للعنوان وإضافة عنصر جديد
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();

  // تاريخ اليوم كافتراضي
  DateTime _selectedDate = DateTime.now();

  // قائمة العناصر المضافة حديثاً
  List<Map<String, dynamic>> _checklistItems = [];

  @override
  void initState() {
    super.initState();

    // 1. قراءة البيانات القديمة لو جايين لتعديل نوتة سابقة
    if (widget.existingNote != null) {
      _titleController.text = widget.existingNote!['title'] ?? '';

      // استرجاع عناصر الـ Checklist
      if (widget.existingNote!['items'] != null) {
        _checklistItems = List<Map<String, dynamic>>.from(
          (widget.existingNote!['items'] as List).map((item) => {
            'title': item['title'],
            'isDone': item['isDone'],
          }),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _itemController.dispose();
    super.dispose();
  }

  // دالة اختيار التاريخ الحقيقي عند الضغط
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

  // حفظ الملاحظة والرجوع للهوم سكرين مع الملاحظة (جديدة أو معدلة)
  void _saveAndPop() {
    final titleText = _titleController.text.trim();
    if (titleText.isNotEmpty || _checklistItems.isNotEmpty) {
      final savedNote = {
        // الحفاظ على الـ id القديم في حالة التعديل
        'id': widget.existingNote != null
            ? widget.existingNote!['id']
            : DateTime.now().millisecondsSinceEpoch.toString(),
        'date': DateFormat('d MMM').format(_selectedDate),
        'title': titleText.isEmpty ? 'New Note' : titleText,
        'items': _checklistItems,
        'timeAgo': 'Just now',
        'isChecklist': true,
      };
      Navigator.pop(context, savedNote);
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
            // 1. الشريط العلوي (Top Bar)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // زرار الـ X للإلغاء والرجوع
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
                      // زرار Save الحفظ الصريح
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

            // محتوى الشاشة
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // التاريخ القابل للضغط لاختيار تاريخ حقيقي
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

                    // حقل كتابة العنوان الرئيسي (مثل Shopping List أو Quiz)
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

                    // قائمة العناصر المضافة المباشرة
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
                              // زرار حذف عنصر منفرد من القائمة
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

                    // حقل إدخال عنصر جديد
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _itemController,
                            style: const TextStyle(color: AppColors.primaryText),
                            decoration: const InputDecoration(
                              hintText: 'Add new item...',
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
                          icon: const Icon(Icons.add, color: Color(0xFF8AC53E)),
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