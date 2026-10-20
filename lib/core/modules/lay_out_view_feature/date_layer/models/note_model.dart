import '../../domain/entity/note_entity.dart';

class NoteModel extends NoteEntity {
  NoteModel({
    super.id,
    required super.title,
    required super.content,
    super.imagePath,
    required super.date,
  });
  // التحويل من Firebase لـ NoteModel
  factory NoteModel.fromJson(Map<String, dynamic> json, String id) {
    return NoteModel(
      id: id,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imagePath: json['imagePath'],
      date: json['date'] ?? '',
    );
  }
  // التحويل من NoteModel لـ Map عشان نرفعها لـ Firebase
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'imagePath': imagePath,
      'date': date,
    };
  }
}