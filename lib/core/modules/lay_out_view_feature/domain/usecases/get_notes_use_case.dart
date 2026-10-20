import 'package:notes_app/core/modules/lay_out_view_feature/domain/repository/notes_repository.dart';

import '../entity/note_entity.dart';

class GetNotesUseCase {

  final NotesRepository repository;

  GetNotesUseCase(this.repository);

  Future<List<NoteEntity>> call() async {
    return await repository.getNotes();
  }
}