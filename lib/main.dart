import 'package:flutter/material.dart';
import 'package:writer/screens/text_editor.dart';

import 'screens/home_page.dart';
import 'services/services.dart';

// --- /data/user/0/com.example.writer/app_flutter/note.hive

void main() async {
  // await Services.initApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primarySwatch: Colors.teal,
        fontFamily: 'Georgia',
      ),
      debugShowCheckedModeBanner: false,
      home: TextEditor(),
    );
  }
}
