import 'package:flutter/material.dart';

import 'screens/home_page.dart';
import 'services/services.dart';

  // --- /data/user/0/com.example.writer/app_flutter/note.hive

void main() async {
  await Services.initApp();
  runApp(MyApp());
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
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
      home: HomePage(),
    );
  }
}
