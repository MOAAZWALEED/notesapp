import 'package:notes_app/core/modules/lay_out_view_feature/domain/repository/notes_repository.dart';

class DeleteNotesUseCase {
  final NotesRepository repository;

  DeleteNotesUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteNote(id);
  }
}