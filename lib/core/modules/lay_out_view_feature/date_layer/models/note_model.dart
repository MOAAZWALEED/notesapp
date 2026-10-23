import '../../domain/entity/note_entity.dart';

class NoteModel extends NoteEntity {
  NoteModel({
    super.id,
    required super.title,
    required super.content,
    super.imagePath,
    required super.date,
    super.filePath,
    super.reminderDateTime,
  });
  // التحويل من Firebase لـ NoteModel
  factory NoteModel.fromJson(Map<String, dynamic> json, String id) {
    return NoteModel(
      id: id,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imagePath: json['imagePath'],
      date: json['date'] ?? '',
      filePath: json['filePath'],
      reminderDateTime: json['reminderDateTime'] != null
        ? DateTime.parse(json['reminderDateTime'])
          : null,
    );
  }
  // التحويل من NoteModel لـ Map عشان نرفعها لـ Firebase
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'imagePath': imagePath,
      'date': date,
      'filePath': filePath,
      'reminderDateTime': reminderDateTime?.toIso8601String(),
    };
  }
}