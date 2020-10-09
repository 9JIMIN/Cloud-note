import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 0)
class Settings extends HiveObject {
  @HiveField(0)
  bool isDarkMode;
  @HiveField(1)
  String rootPath;
  @HiveField(2)
  String lastOpenNoteName;

  Settings({
    this.isDarkMode,
    this.rootPath,
    this.lastOpenNoteName,
  });
}
