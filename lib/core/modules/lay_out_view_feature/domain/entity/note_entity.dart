class NoteEntity {
  final String? id;
  final String title;
  final String content;
  final String? imagePath;
  final String date;
  final DateTime? reminderDateTime;
  final String? filePath;

  NoteEntity({
    this.id,
    required this.title,
    required this.content,
    this.imagePath,
    required this.date,
    this.reminderDateTime,
    this.filePath,
  });
}