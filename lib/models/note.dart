import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 1)
class Note extends HiveObject {
  @HiveField(0)
  String title;
  @HiveField(1)
  DateTime lastModified;
  @HiveField(2)
  String fileName;
  @HiveField(3)
  int parentKey;
  @HiveField(4)
  bool isFold;

  Note({
    this.title,
    this.lastModified,
    this.fileName,
    this.parentKey,
    this.isFold,
  });
}

// flutter packages pub run build_runner build