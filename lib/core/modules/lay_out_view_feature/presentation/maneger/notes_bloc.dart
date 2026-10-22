import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/core/Services/notification_service.dart';
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

        // جدولة الإشعار على الجهاز لو فيه وقت ألارم
        if (event.note.reminderDateTime != null) {
          await NotificationService.scheduleNotification(
            id: event.note.id.hashCode,
            title: event.note.title,
            body: event.note.content,
            scheduledDate: event.note.reminderDateTime!,
          );
        }

        final notes = await getNotesUseCase();
        emit(NoteSuccessState(notes));
      } catch (e) {
        emit(NoteErrorState(e.toString()));
      }
    });

    on<UpdateNoteEvent>((event, emit) async {
      try {
        await updateNoteUseCase(event.note);

        // تحديث أو جدولة الإشعار لو الوقت موجود، أو إلغاؤه لو تم حذفه
        if (event.note.reminderDateTime != null) {
          await NotificationService.scheduleNotification(
            id: event.note.id.hashCode,
            title: event.note.title,
            body: event.note.content,
            scheduledDate: event.note.reminderDateTime!,
          );
        } else {
          await NotificationService.cancelNotification(event.note.id.hashCode);
        }

        final notes = await getNotesUseCase();
        emit(NoteSuccessState(notes));
      } catch (e) {
        emit(NoteErrorState(e.toString()));
      }
    });

    on<DeleteNoteEvent>((event, emit) async {
      try {
        await deleteNoteUseCase(event.id);

        // إلغاء الإشعار عند حذف النوتة
        await NotificationService.cancelNotification(event.id.hashCode);

        final notes = await getNotesUseCase();
        emit(NoteSuccessState(notes));
      } catch (e) {
        emit(NoteErrorState(e.toString()));
      }
    });
  }
}