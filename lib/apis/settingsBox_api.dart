import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/settings.dart';

class SettingsBoxApi {
  static Box<Settings> get settingsBox => Hive.box<Settings>('settings');
  static Settings get settingsModel => settingsBox.get(0);

  static Future<void> registerAndOpenBox() async {
    Hive.registerAdapter<Settings>(SettingsAdapter());
    await Hive.openBox<Settings>('settings');
  }

  static Future<void> initBox(String initalFileName) async {
    final rootDirectory = await getApplicationDocumentsDirectory();
    final rootPath = rootDirectory.path;

    await settingsBox.add(Settings(
      isDarkMode: true,
      rootPath: rootPath,
      lastOpenNoteName: initalFileName,
    ));
  }

  static Future<void> updateLastOpenNoteName(String fileName) async {
    settingsModel.lastOpenNoteName = fileName;
    await settingsModel.save();
  }
}
