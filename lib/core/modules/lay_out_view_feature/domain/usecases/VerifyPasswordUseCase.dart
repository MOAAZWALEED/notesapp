import 'package:notes_app/core/modules/lay_out_view_feature/domain/repository/notes_repository.dart';

class Verifypasswordusecase {
  final NotesRepository repository;
  Verifypasswordusecase(this.repository);

  Future<bool> call({required String noteId, required String password}) async {
    return await repository.verifyPassword(noteId: noteId, password: password);
  }
}