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
      isPrivate: note.isPrivate,
      password: note.password,
      reminderDateTime: note.reminderDateTime,
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
      isPrivate: note.isPrivate,
      password: note.password,
      reminderDateTime: note.reminderDateTime,
    );
    await remoteDataSource.updateNote(noteModel);
  }

  @override
  Future<void> deleteNote(String id) async {
    await remoteDataSource.deleteNote(id);
  }

  @override
  Future<bool> verifyPassword({required String noteId, required String password}) async {
    return await remoteDataSource.verifyPassword(noteId: noteId, password: password);
  }

  @override
  Future<void> updatePassword({required String noteId, required String oldPassword, required String newPassword}) async {
    return await remoteDataSource.updatePassword(noteId: noteId, oldPassword: oldPassword, newPassword: newPassword);
  }
}