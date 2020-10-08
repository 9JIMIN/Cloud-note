import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:writer/models/settings.dart';
import 'package:zefyr/zefyr.dart';

import 'models/note.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  ZefyrController _controller;
  FocusNode _focusNode;
  Settings settings = Hive.box<Settings>('settings').get(0);

  Future<void> fetchNote() async {
    getApplicationDocumentsDirectory();
  }

  Future<NotusDocument> _loadDocument() async {
    final file = File(
        settings.rootPath + '/json/' + settings.lastOpenNotePath + '.json');
    print(file.path);
    if (await file.exists()) {
      final contents = await file.readAsString();
      return NotusDocument.fromJson(jsonDecode(contents));
    }
    final Delta delta = Delta()..insert("file no\n");
    return NotusDocument.fromDelta(delta);
  }

  Future<void> _saveDocument(BuildContext context) async {
    final directory =
        await getApplicationDocumentsDirectory(); // '/data/user/0/com.example.writer/app_flutter'
    final file = File(directory.path + '/json/test.json');
    print(file.path); // 확인용.
    final contents = jsonEncode(_controller.document);
    await file.writeAsString(contents);
    Scaffold.of(context).showSnackBar(SnackBar(content: Text('done')));
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _loadDocument().then((document) {
      setState(() {
        _controller = ZefyrController(document);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Note>('note').listenable(),
      builder: (context, Box<Note> box, _) => Scaffold(
        drawer: Drawer(
          child: ListView(
            children: [
              SizedBox(
                height: 60,
                child: DrawerHeader(
                  child: Text('123'),
                  decoration: BoxDecoration(color: Colors.indigo),
                ),
              ),
              if (box.values.isNotEmpty)
                for (Note note in box.values)
                  ListTile(
                    title: Text(note.title),
                    subtitle: Text(note.lastModified.toString()),
                    trailing: Text(note.notePath),
                  )
            ],
          ),
        ),
        backgroundColor: Colors.blueGrey[900],
        appBar: AppBar(
          title: Text("Editor page"),
          actions: [
            IconButton(
                icon: Icon(Icons.save),
                onPressed: () async {
                  await _saveDocument(context);
                })
          ],
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          height: 1000,
          child: Form(
            key: GlobalKey<FormState>(),
            child: Column(
              children: [
                TextFormField(
                  initialValue: box.values
                      .firstWhere((element) =>
                          element.notePath == settings.lastOpenNotePath)
                      .title,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(hintText: 'title'),
                ),
                _controller == null
                    ? Center(child: CircularProgressIndicator())
                    : Expanded(
                        child: ZefyrScaffold(
                          child: ZefyrEditor(
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 0,
                            ),
                            controller: _controller,
                            focusNode: _focusNode,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
