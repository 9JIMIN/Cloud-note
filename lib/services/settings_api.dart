import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/settings.dart';

class SettingsApi {
  static Box<Settings> get settingsBox => Hive.box<Settings>('settings');
  static Settings get settingsModel => settingsBox.get(0);

  static Future<void> openSettingsBox() async {
    Hive.registerAdapter<Settings>(SettingsAdapter());
    await Hive.openBox<Settings>('settings');
  }

  static Future<void> initSettings() async {
    final rootDirectory = await getApplicationDocumentsDirectory();
    final rootPath = rootDirectory.path;
    final fileName = DateTime.now().toIso8601String();
    await settingsBox.add(Settings(
      isDarkMode: true,
      rootPath: rootPath,
      lastOpenNoteName: fileName,
    ));
  }

  static Future<void> updateLastOpenNoteName(String fileName) async {
    settingsModel.lastOpenNoteName = fileName;
    await settingsModel.save();
  }
}
