import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zefyr/zefyr.dart';

import '../models/note.dart';
import '../models/settings.dart';
import '../services/services.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  ZefyrController _controller;
  String _title;
  NotusDocument _document;

  FocusNode _titleNode = FocusNode();
  FocusNode _contentNode = FocusNode();

  Future<void> fetchData() async {
    Services.getNote().then((note) => _title = note.title);
    _document = await Services.getDocument();
    print(_document.toString());
    setState(() {
      _controller = ZefyrController(_document);
    });
  }

  Future<void> navigateFile(fileName) async {
    await Services.updateLastNote(fileName);
    await fetchData();
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Note>('notes').listenable(),
      builder: (context, Box<Note> box, _) {
        print('rebuild');
        return Scaffold(
          drawer: Drawer(
            child: ListView(
              children: [
                SizedBox(
                  height: 60,
                  child: DrawerHeader(
                    child: RaisedButton(
                      child: Text('add new'),
                      onPressed: () async {
                        await Services.addNote();
                      },
                    ),
                    decoration: BoxDecoration(color: Colors.indigo),
                  ),
                ),
                if (box.values.isNotEmpty)
                  for (Note note in box.values)
                    GestureDetector(
                      onTap: () async {
                        await navigateFile(note.fileName);
                      },
                      child: ListTile(
                        title: Text(note.title),
                        subtitle: Text(note.lastModified.toString()),
                        trailing: Text(note.fileName),
                      ),
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
                    await Services.saveNote(_title, _document);
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
                    focusNode: _titleNode,
                    initialValue: _title,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(hintText: 'title'),
                    onChanged: (value) => _title = value,
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
                              focusNode: _contentNode,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
