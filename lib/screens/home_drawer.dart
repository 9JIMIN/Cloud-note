import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/note.dart';
import '../services/services.dart';

class HomeDrawer extends StatelessWidget {
  final Function selectNote;
  HomeDrawer(this.selectNote);

  @override
  Widget build(BuildContext context) {
    print('**drawer build');
    return Drawer(
      child: ValueListenableBuilder(
          valueListenable: Hive.box<Note>('notes').listenable(),
          builder: (context, Box<Note> box, _) {
            // key에 맞는 위젯 리스트를 반환하는 함수
            List<Widget> getNotesByParentKey(int key) {
              List<Widget> widgetList = List<Widget>();
              print(widgetList.length);
              for (Note note in box.values) {
                print(
                    '노트 키: ${note.key} // 노트 부모키: ${note.parentKey} // 노트 파일명: ${note.fileName}');
              }
              widgetList.add(SizedBox(height: 20));
              if (!box.values.any((note) => note.parentKey == key)) {
                print('요소없음');
                List<Widget> emptyList = List();
                emptyList.add(ListTile(
                  leading: Icon(Icons.hourglass_empty),
                  title: Text('empty folder'),
                ));
                return emptyList;
              }
              box.values.where((note) => note.parentKey == key).forEach((note) {
                if (note.fileName == 'folder') {
                  if (note.isFold) {
                    widgetList.add(
                      ListTile(
                        leading: Icon(Icons.folder_open),
                        title: Text(note.title),
                        subtitle: Text(note.lastModified.toIso8601String()),
                        trailing: PopupMenuButton<int>(
                            onSelected: (value) async {
                              if (value == 1) {
                                // await Services.deleteNote(note.fileName);
                              } else if (value == 2) {
                                await Services.addNote(note.key);
                              } else if (value == 3) {
                                await Services.addFolder(note.key);
                              }
                            },
                            itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 1,
                                    child: Text('delete'),
                                  ),
                                  PopupMenuItem(
                                    value: 2,
                                    child: Text('add note'),
                                  ),
                                  PopupMenuItem(
                                    value: 3,
                                    child: Text('add folder'),
                                  ),
                                ]),
                        onTap: () async {
                          await Services.toggleIsFold(note.key);
                        },
                      ),
                    );
                  } else {
                    widgetList.add(
                      ListTile(
                        leading: Icon(Icons.folder),
                        title: Text(note.title),
                        subtitle: Text(note.lastModified.toIso8601String()),
                        trailing: PopupMenuButton<int>(
                            onSelected: (value) async {
                              if (value == 1) {
                                // await Services.deleteNote(note.fileName);
                              } else if (value == 2) {
                                await Services.addNote(note.key);
                              } else if (value == 3) {
                                await Services.addFolder(note.key);
                              }
                            },
                            itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 1,
                                    child: Text('delete'),
                                  ),
                                  PopupMenuItem(
                                    value: 2,
                                    child: Text('add note'),
                                  ),
                                  PopupMenuItem(
                                    value: 3,
                                    child: Text('add folder'),
                                  ),
                                ]),
                        onTap: () async {
                          await Services.toggleIsFold(note.key);
                        },
                      ),
                    );
                    widgetList.add(
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Column(
                          // children: getNotesByParentKey(note.key),
                          children: getNotesByParentKey(note.key),
                        ),
                      ),
                    );
                  }
                } else {
                  widgetList.add(ListTile(
                    leading: Icon(Icons.text_snippet),
                    title: Text(note.title),
                    subtitle: Text(note.lastModified.toIso8601String()),
                    trailing: PopupMenuButton<int>(
                        onSelected: (value) async {
                          if (value == 1) {
                            await Services.deleteNote(note.fileName);
                          } else if (value == 2) {
                            await Services.addNote(note.parentKey);
                          } else if (value == 3) {
                            await Services.addFolder(note.parentKey);
                          }
                        },
                        itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 1,
                                child: Text('delete'),
                              ),
                              PopupMenuItem(
                                value: 2,
                                child: Text('add note to this path'),
                              ),
                              PopupMenuItem(
                                value: 3,
                                child: Text('add folder to this path'),
                              ),
                            ]),
                    onTap: () async {
                      await selectNote(note.fileName);
                    },
                  ));
                }
              });

              return widgetList;
            }

            return Column(children: getNotesByParentKey(0));
          }),
    );
  }
}
