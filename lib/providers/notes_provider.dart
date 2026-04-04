import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/database_service.dart';

class NotesProvider with ChangeNotifier {
  List<Note> _notes = [];

  List<Note> get notes => _notes;

  NotesProvider() {
    loadNotes();
  }

  Future<void> loadNotes() async {
    _notes = await DatabaseService.instance.getNotes();
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    await DatabaseService.instance.insertNote(note);
    _notes.insert(0, note);
    notifyListeners();
  }

  Future<void> updateNote(String id, String content) async {
    final noteIndex = _notes.indexWhere((note) => note.id == id);
    if (noteIndex != -1) {
      await DatabaseService.instance.updateNote(id, content);
      _notes[noteIndex].content = content;
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    await DatabaseService.instance.deleteNote(id);
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }
}
