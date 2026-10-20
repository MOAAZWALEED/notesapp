import '../../domain/entity/note_entity.dart';

abstract class NotesState {}

class NoteInitialState extends NotesState {}

class NoteLoadingState extends NotesState {}

class NoteSuccessState extends NotesState {
  final List<NoteEntity> notes;
  NoteSuccessState(this.notes);
}
class NoteErrorState extends NotesState {
  final String message;
  NoteErrorState(this.message);
}