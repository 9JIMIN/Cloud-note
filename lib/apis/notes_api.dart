import 'package:hive/hive.dart';
import 'package:writer/models/note.dart';

class NotesApi {
  static Box<Note> get notesBox => Hive.box<Note>('notes');

  static Future<void> openNotesBox() async {
    Hive.registerAdapter<Note>(NoteAdapter());
    await Hive.openBox<Note>('notes');
  }

  static Future<void> initNote() async {
    await notesBox.add(Note());
    await notesBox.delete(0);
  }

  static Future<void> toggleIsFold(int key) async {
    final targetNote = notesBox.get(key);
    targetNote.isFold = !targetNote.isFold;
    targetNote.save();
  }

  static Future<void> addFolder(int parentKey) async {
    print('addFolder parentKey: $parentKey');
    final Note folder = Note(
      title: '제목없는 폴더',
      isFold: false,
      fileName: 'folder',
      lastModified: DateTime.now(),
      parentKey: parentKey,
    );
    await notesBox.add(folder);
  }

  static Future<Note> getNoteByName(String fileName) async {
    print(notesBox.path);
    return notesBox.values.firstWhere((note) => note.fileName == fileName);
  }

  static Future<void> addNote(
    String title,
    String fileName,
    int parentKey,
  ) async {
    final Note note = Note(
      title: title,
      fileName: fileName,
      lastModified: DateTime.now(),
      parentKey: parentKey,
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
