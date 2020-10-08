import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 1)
class Note extends HiveObject {
  @HiveField(0)
  String title;
  @HiveField(1)
  DateTime lastModified;
  @HiveField(2)
  String notePath;

  Note({
    this.title,
    this.lastModified,
    this.notePath,
  });
}
