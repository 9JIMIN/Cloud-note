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
        builder: (context, Box<Note> box, _) => ListView(
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
                    print('123');
                    await this.selectNote(note.fileName);
                  },
                  child: ListTile(
                    title: Text(note.title),
                    subtitle: Text(note.lastModified.toString()),
                    trailing: PopupMenuButton<int>(
                        onSelected: (value) async {
                          if (value == 1) {
                            await Services.deleteNote(note.fileName);
                          }
                        },
                        itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 1,
                                child: Text('delete'),
                              ),
                              PopupMenuItem(
                                value: 2,
                                child: Text('more...'),
                              ),
                            ]),
                  ),
                )
          ],
        ),
      ),
    );
  }
}
