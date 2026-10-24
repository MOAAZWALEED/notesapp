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

// حالات التحقق من كلمة المرور الجديدة
class VerifyPasswordLoadingState extends NotesState {}

class VerifyPasswordSuccessState extends NotesState {
  final bool isValid;
  VerifyPasswordSuccessState(this.isValid);
}

class VerifyPasswordFailureState extends NotesState {
  final String errorMessage;
  VerifyPasswordFailureState(this.errorMessage);
}

// حالات تحديث كلمة المرور الجديدة
class UpdatePasswordLoadingState extends NotesState {}

class UpdatePasswordSuccessState extends NotesState {}

class UpdatePasswordFailureState extends NotesState {
  final String errorMessage;
  UpdatePasswordFailureState(this.errorMessage);
}