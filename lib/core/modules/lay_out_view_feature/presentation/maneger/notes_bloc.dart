import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/core/Services/notification_service.dart';
import '../../domain/usecases/VerifyPasswordUseCase.dart';
import '../../domain/usecases/add_notes_use_case.dart';
import '../../domain/usecases/delete_notes_use_case.dart';
import '../../domain/usecases/get_notes_use_case.dart';
import '../../domain/usecases/update_note_use_case.dart';
import '../../domain/usecases/​UpdatePasswordUseCase.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final GetNotesUseCase getNotesUseCase;
  final AddNotesUseCase addNoteUseCase;
  final UpdateNoteUseCase updateNoteUseCase;
  final DeleteNotesUseCase deleteNoteUseCase;
  final Verifypasswordusecase verifyPasswordUseCase; // متغير التحقق
  final updatepasswordusecase updatePasswordUseCase; // متغير التحديث

  NotesBloc({
    required this.getNotesUseCase,
    required this.addNoteUseCase,
    required this.updateNoteUseCase,
    required this.deleteNoteUseCase,
    required this.verifyPasswordUseCase, // تمريرها في الكونستركتور
    required this.updatePasswordUseCase, // تمريرها في الكونستركتور
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

        // جدولة الإشعار مع إخفاء بيانات النوتة لو كانت Private
        if (event.note.reminderDateTime != null) {
          final title = event.note.isPrivate ? 'Private Note 🔒' : event.note.title;
          final body = event.note.isPrivate
              ? 'Locked note reminder.'
              : event.note.content;

          await NotificationService.scheduleNotification(
            id: event.note.id.hashCode,
            title: title,
            body: body,
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

        // تحديث أو جدولة الإشعار مع إخفاء بيانات النوتة لو كانت Private
        if (event.note.reminderDateTime != null) {
          final title = event.note.isPrivate ? 'Private Note 🔒' : event.note.title;
          final body = event.note.isPrivate
              ? 'You have a scheduled reminder for a secure note.'
              : event.note.content;

          await NotificationService.scheduleNotification(
            id: event.note.id.hashCode,
            title: title,
            body: body,
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

    // التعامل مع التحقق من كلمة المرور
    on<VerifyNotePasswordEvent>((event, emit) async {
      emit(VerifyPasswordLoadingState());
      try {
        final isValid = await verifyPasswordUseCase(
          noteId: event.noteId,
          password: event.password,
        );
        emit(VerifyPasswordSuccessState(isValid));
      } catch (e) {
        emit(VerifyPasswordFailureState(e.toString()));
      }
    });

    // التعامل مع تحديث كلمة المرور
    on<UpdateNotePasswordEvent>((event, emit) async {
      emit(UpdatePasswordLoadingState());
      try {
        await updatePasswordUseCase(
          noteId: event.noteId,
          oldPassword: event.oldPassword,
          newPassword: event.newPassword,
        );
        emit(UpdatePasswordSuccessState());
      } catch (e) {
        emit(UpdatePasswordFailureState(e.toString()));
      }
    });
  }
}