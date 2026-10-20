import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_notes_use_case.dart';
import '../../domain/usecases/delete_notes_use_case.dart';
import '../../domain/usecases/get_notes_use_case.dart';
import '../../domain/usecases/update_note_use_case.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final GetNotesUseCase getNotesUseCase;
  final AddNotesUseCase addNoteUseCase;
  final UpdateNoteUseCase updateNoteUseCase;
  final DeleteNotesUseCase deleteNoteUseCase;

  NotesBloc({
    required this.getNotesUseCase,
    required this.addNoteUseCase,
    required this.updateNoteUseCase,
    required this.deleteNoteUseCase,
  }) : super(NoteInitialState()) {

    on<FetchNotesEvent>((event, emit) async {
      emit(NoteLoadingState());
      try {
        final notes = await getNotesUseCase();
        emit(NoteSuccessState(notes));
      } catch (e) {
        emit(NoteErrorState(e.toString()));
      }
    });

    on<AddNoteEvent>((event, emit) async {
      try {
        await addNoteUseCase(event.note);
        final notes = await getNotesUseCase();
        emit(NoteSuccessState(notes));
      } catch (e) {
        emit(NoteErrorState(e.toString()));
      }
    });

    on<UpdateNoteEvent>((event, emit) async {
      try {
        await updateNoteUseCase(event.note);
        final notes = await getNotesUseCase();
        emit(NoteSuccessState(notes));
      } catch (e) {
        emit(NoteErrorState(e.toString()));
      }
    });

    on<DeleteNoteEvent>((event, emit) async {
      try {
        await deleteNoteUseCase(event.id);
        final notes = await getNotesUseCase();
        emit(NoteSuccessState(notes));
      } catch (e) {
        emit(NoteErrorState(e.toString()));
      }
    });
  }
}