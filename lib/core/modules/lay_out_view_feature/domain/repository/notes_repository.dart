import '../entity/note_entity.dart';

abstract class NotesRepository {
  Future<List<NoteEntity>> getNotes();
  Future<void> addNote(NoteEntity note);
  Future<void> updateNote(NoteEntity note);
  Future<void> deleteNote(String id);
  Future<bool> verifyPassword({required String noteId, required String password});
  Future<void> updatePassword({required String noteId, required String oldPassword, required String newPassword});
}