import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:writer/cloud/google_auth_client.dart';
import 'package:writer/cloud/google_drive.dart';
import 'package:writer/screens/home_drawer.dart';
import 'package:zefyr/zefyr.dart';

import '../models/note.dart';
import '../models/settings.dart';
import '../services/services.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  FocusNode _titleNode = FocusNode();
  FocusNode _contentNode = FocusNode();

  Note _note;
  NotusDocument _document;
  ZefyrController _controller;

  Future<void> fetchData() async {
    _note = await Services.getNote();
    _document = await Services.getDocument();
    _controller = ZefyrController(_document);
    print(_document.toString());
  }

  Future<void> selectNote(fileName) async {
    await Services.updateLastNote(fileName);
    await fetchData();
    setState(() {});
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    print('**home page build');
    return Scaffold(
      drawer: HomeDrawer(selectNote),
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: Text("Editor page"),
        actions: [
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () async {
                await Services.saveNote(_note, _document);
              }),
          IconButton(
              icon: Icon(Icons.cloud),
              onPressed: () async {
                await GoogleDrive.uploadFile(Services.rootPath);
              }),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        height: 1000,
        child: Form(
          key: GlobalKey<FormState>(),
          child: FutureBuilder(
              future: fetchData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Column(
                    children: [
                      TextFormField(
                        focusNode: _titleNode,
                        initialValue: _note.title,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(hintText: 'title'),
                        onChanged: (value) => _note.title = value,
                      ),
                      Expanded(
                        child: ZefyrScaffold(
                          child: ZefyrEditor(
                            imageDelegate:
                                MyAppZefyrImageDelegate(Services.rootPath),
                            focusNode: _contentNode,
                            controller: _controller,
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }),
        ),
      ),
    );
  }
}

class MyAppZefyrImageDelegate implements ZefyrImageDelegate<ImageSource> {
  final String rootPath;
  MyAppZefyrImageDelegate(this.rootPath);

  @override
  Future<String> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(source: source);
    if (pickedFile == null) return null;
    print('picked file path: ' + pickedFile.path);
    final newPath =
        rootPath + '/note-data/image/${DateTime.now().toIso8601String()}.jpg';
        // 여기서 note box에 이미지 이름 추가하고, 삭제시 같이 삭제해줌.
        // ########################################################
    await File(newPath).create(recursive: true);
    await File(pickedFile.path).copy(newPath);
    print(newPath);
    return newPath;
  }

  @override
  Widget buildImage(BuildContext context, String key) {
    final file = File.fromUri(Uri.parse(key));
    print(file.path);
    final image = FileImage(file);
    return Image(image: image);
  }

  @override
  ImageSource get cameraSource => ImageSource.camera;

  @override
  ImageSource get gallerySource => ImageSource.gallery;
}
