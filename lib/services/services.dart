import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zefyr/zefyr.dart';

import '../models/note.dart';
import '../apis/notesBox_api.dart';
import '../apis/settingsBox_api.dart';
import '../apis/document_api.dart';

// 이 서비스 클래스는 싱글톤으로 항상 떠 있게 하자.

class Services {
  // static String get rootPath => SettingsBoxApi.settingsModel.rootPath;
  static String get lastOpenFileName =>
      SettingsBoxApi.settingsModel.lastOpenNoteName;

  static String get lastOpenFilePath =>
      SettingsBoxApi.settingsModel.rootPath +
      '/note-data/json/$lastOpenFileName.json';

  String rootPath;
  String jsonPath;

  String toJsonPath(String fileName) =>
      rootPath + '/documents/json/$fileName.json';

  // 1-1. 처음 열때
  // ****************************************************
  Future<void> initApp() async {
    await Hive.initFlutter();
    await SettingsBoxApi.registerAndOpenBox();
    await NotesBoxApi.registerAndOpenBox();
    await getApplicationDocumentsDirectory()
        .then((directory) => rootPath = directory.path);
    // 세팅박스가 있는지 확인
    if (SettingsBoxApi.settingsBox.isEmpty) {
      final initalFileName = DateTime.now().toIso8601String();
      await SettingsBoxApi.initBox(initalFileName);
      await NotesBoxApi.initBox(initalFileName);
      await DocumentApi.initDocument(toJsonPath(initalFileName));
    }
  }

  static Future<void> toggleIsFold(key) async {
    await NotesBoxApi.toggleIsFold(key);
  }

  static Future<void> addFolder(int parentKey) async {
    await NotesBoxApi.addFolder(parentKey);
  }

  // 2-1. 노트 읽기
  // **************************************
  static Future<Note> getNote() async {
    final Note note = await NotesBoxApi.getNoteByName(lastOpenFileName);
    return note;
  }

  // 2-2. 파일 읽기
  static Future<NotusDocument> getDocument() async {
    final contents = await File(lastOpenFilePath).readAsString();
    return NotusDocument.fromJson(jsonDecode(contents));
  }

  // 3. 저장
  static Future<void> saveNote(Note note, NotusDocument document) async {
    await NotesBoxApi.updateNote(note.title, lastOpenFileName);
    await DocumentApi.updateDocument(document, lastOpenFilePath);
  }

  // 4. 세팅 문서 업데이트
  static Future<void> updateLastNote(String fileName) async {
    await SettingsBoxApi.updateLastOpenNoteName(fileName);
  }

  // 5. 문서 삭제
  static Future<void> deleteNote(String fileName) async {
    if (SettingsBoxApi.settingsModel.lastOpenNoteName == fileName) {
      // 현재 문서가 삭제되면, 텅비워줌.
      await SettingsBoxApi.updateLastOpenNoteName('empty');
    }
    final Note note = await NotesBoxApi.getNoteByName(fileName);
    await NotesBoxApi.deleteNote(note);
    await DocumentApi.deleteDocument(SettingsBoxApi.settingsModel.rootPath +
        '/note-data/json/$fileName.json');
  }

  // 6. 문서 생성
  static Future<void> addNote(int parentKey) async {
    final document =
        await DocumentApi.stringToDocument('아무내용도 없을때는 어떻게 해야함?\n');
    final title = '제목없음';

    final newFileName = DateTime.now().toIso8601String();
    final newFilePath = SettingsBoxApi.settingsModel.rootPath +
        '/note-data/json/$newFileName.json';

    await DocumentApi.addDocument(document, newFilePath);
    await NotesBoxApi.addNote(title, newFileName, parentKey);
  }
}
