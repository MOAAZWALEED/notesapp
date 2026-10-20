import 'package:notes_app/core/modules/lay_out_view_feature/domain/repository/notes_repository.dart';

import '../entity/note_entity.dart';

class UpdateNoteUseCase {

  final NotesRepository repository;

  UpdateNoteUseCase(this.repository);

  Future<void> call(NoteEntity note) async {
    await repository.updateNote(note);
  }
}