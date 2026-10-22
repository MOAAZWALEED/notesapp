import '../../domain/entity/note_entity.dart';
import '../../domain/repository/notes_repository.dart';
import '../datesourse/notes_remote_date_source.dart';
import '../models/note_model.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesRemoteDataSource remoteDataSource;

  NotesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<NoteEntity>> getNotes() async {
    final notesModels = await remoteDataSource.getNotes();
    return notesModels;
  }

  @override
  Future<void> addNote(NoteEntity note) async {
    final noteModel = NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      imagePath: note.imagePath,
      date: note.date,
      reminderDateTime: note.reminderDateTime, // ضفنا الحقل هنا
    );
    await remoteDataSource.addNote(noteModel);
  }

  @override
  Future<void> updateNote(NoteEntity note) async {
    final noteModel = NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      imagePath: note.imagePath,
      date: note.date,
      reminderDateTime: note.reminderDateTime, // وضفناه هنا كمان
    );
    await remoteDataSource.updateNote(noteModel);
  }

  @override
  Future<void> deleteNote(String id) async {
    await remoteDataSource.deleteNote(id);
  }
}