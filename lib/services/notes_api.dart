import 'package:hive/hive.dart';
import 'package:writer/models/note.dart';

class NotesApi {
  static Box<Note> get notesBox => Hive.box<Note>('notes');

  static Future<void> openNotesBox() async {
    Hive.registerAdapter<Note>(NoteAdapter());
    await Hive.openBox<Note>('notes');
  }

  static Future<Note> getNoteByName(String fileName) async {
    print(notesBox.path);
    return notesBox.values.firstWhere((note) => note.fileName == fileName);
  }

  static Future<void> addNote(String title, String fileName) async {
    final Note note = Note(
      title: title,
      fileName: fileName,
      lastModified: DateTime.now(),
    );

    await notesBox.add(note);
  }

  static Future<void> updateNote(String title, String fileName) async {
    final Note note = await getNoteByName(fileName);
    note.title = title;
    note.lastModified = DateTime.now();
    await note.save();
  }

  static Future<void> deleteNote(Note note) async {
    await note.delete();
  }
}
