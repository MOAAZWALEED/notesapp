import '../../domain/entity/note_entity.dart';

abstract class NotesEvent {}

class FetchNotesEvent extends NotesEvent {}

class AddNoteEvent extends NotesEvent {
  final NoteEntity note;
  AddNoteEvent(this.note);
}

class UpdateNoteEvent extends NotesEvent {
  final NoteEntity note;
  UpdateNoteEvent(this.note);
}

class DeleteNoteEvent extends NotesEvent {
  final String id;
  DeleteNoteEvent(this.id);
}