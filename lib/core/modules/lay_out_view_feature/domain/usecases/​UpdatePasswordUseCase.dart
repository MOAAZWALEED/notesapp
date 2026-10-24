import 'package:notes_app/core/modules/lay_out_view_feature/domain/repository/notes_repository.dart';

class updatepasswordusecase {
  final NotesRepository repository;
  updatepasswordusecase(this.repository);

  Future<void> call({required String noteId, required String oldPassword, required String newPassword}) async {
    return await repository.updatePassword(noteId: noteId, oldPassword: oldPassword, newPassword: newPassword);
  }
}