import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';

abstract class NotesRemoteDataSource {
  Future<List<NoteModel>> getNotes();
  Future<void> addNote(NoteModel note);
  Future<void> updateNote(NoteModel note);
  Future<void> deleteNote(String id);
  Future<bool> verifyPassword({required String noteId, required String password});
  Future<void> updatePassword({required String noteId, required String oldPassword, required String newPassword});
}

class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<List<NoteModel>> getNotes() async {
    final snapshot = await firestore.collection('notes').get();
    return snapshot.docs
        .map((doc) => NoteModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> addNote(NoteModel note) async {

    if (note.id != null && note.id!.isNotEmpty) {
      await firestore.collection('notes').doc(note.id).set(note.toJson());
    } else {
      await firestore.collection('notes').add(note.toJson());
    }
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    if (note.id != null && note.id!.isNotEmpty) {
      await firestore.collection('notes').doc(note.id).set(note.toJson(), SetOptions(merge: true));
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    await firestore.collection('notes').doc(id).delete();
  }

  @override
  Future<bool> verifyPassword({required String noteId, required String password}) async {
    final doc = await firestore.collection('notes').doc(noteId).get();
    if (doc.exists) {
      final noteData = doc.data();
      return noteData?['password'] == password;
    }
    return false;
  }

  @override
  Future<void> updatePassword({required String noteId, required String oldPassword, required String newPassword}) async {
    final isCorrect = await verifyPassword(noteId: noteId, password: oldPassword);
    if (isCorrect) {
      await firestore.collection('notes').doc(noteId).update({
        'password': newPassword,
      });
    } else {
      throw Exception('The old password you entered is incorrect');
    }
  }
}