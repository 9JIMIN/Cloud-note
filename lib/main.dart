import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:zefyr/zefyr.dart';

import 'home_page.dart';
import 'models/note.dart';
import 'models/settings.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter<Settings>(SettingsAdapter());
  Hive.registerAdapter<Note>(NoteAdapter());

  await Hive.openBox<Settings>('settings');
  await Hive.openBox<Note>('note');
  // --- /data/user/0/com.example.writer/app_flutter/note.hive
  await initApp();
  runApp(MyApp());
}

Future<void> initApp() async {
  Box settingsBox = Hive.box<Settings>('settings');
  if (settingsBox.isEmpty) {
    final Delta delta = Delta()..insert("welcome\n");
    final document = NotusDocument.fromDelta(delta);
    final contents = jsonEncode(document);

    final directory = await getApplicationDocumentsDirectory();
    final id = DateTime.now().toString().substring(0, 10);
    File(directory.path + '/json/$id.json')
        .create(recursive: true)
        .then((File file) {
      file.writeAsString(contents).then(
          (_) => print('welcome file upload done..!\n contents: $contents'));
    });

    await settingsBox.add(Settings(
      isDarkMode: true,
      rootPath: directory.path,
      lastOpenNotePath: id,
    ));

    Box noteBox = Hive.box<Note>('note');
    await noteBox.add(Note(
      title: 'welcome-title',
      lastModified: DateTime.now(),
      notePath: id,
    ));
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        textTheme: TextTheme(
          bodyText2: TextStyle(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.white),
        ),
      ),
      home: HomePage(),
    );
  }
}
