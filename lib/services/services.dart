import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zefyr/zefyr.dart';

import '../models/note.dart';
import '../apis/notes_api.dart';
import '../apis/settings_api.dart';
import '../apis/zefyr_api.dart';

class Services {
  static String get rootPath => SettingsApi.settingsModel.rootPath;
  static String get lastOpenFileName =>
      SettingsApi.settingsModel.lastOpenNoteName;

  static String get lastOpenFilePath =>
      SettingsApi.settingsModel.rootPath + '/note-data/json/$lastOpenFileName.json';

  // 1-1. 처음 열때
  // ****************************************************
  static Future<void> initApp() async {
    // 박스 열기
    await Hive.initFlutter();
    await SettingsApi.openSettingsBox();
    await NotesApi.openNotesBox();
    // 세팅박스 있는지 확인
    if (SettingsApi.settingsBox.isEmpty) {
      // 이상한게 그냥 함수만 넣으면 이걸 await하지 않음.
      await _whenNoSettings();
      await Future.delayed(Duration(seconds: 0));
    }
  }

  // 1-2. 처음 깔았을때
  static Future<void> _whenNoSettings() async {
    // 세팅 추가
    await SettingsApi.initSettings();
    await NotesApi.initNote();
    final initTitle = 'welcome to my app';
    final initContent = 'welcome to my note app\n';
    final document = await ZefyrApi.stringToDocument(initContent);
    await ZefyrApi.addDocument(
      document,
      lastOpenFilePath,
    );
    // 노트 추가
    await NotesApi.addNote(
      initTitle,
      lastOpenFileName,
      0
    );
  }

  static Future<void> toggleIsFold(key) async{
    await NotesApi.toggleIsFold(key);
  }

  static Future<void> addFolder(int parentKey) async{
    await NotesApi.addFolder(parentKey);
  }

  // 2-1. 노트 읽기
  // **************************************
  static Future<Note> getNote() async {
    final Note note = await NotesApi.getNoteByName(lastOpenFileName);
    return note;
  }

  // 2-2. 파일 읽기
  static Future<NotusDocument> getDocument() async {
    final contents = await File(lastOpenFilePath).readAsString();
    return NotusDocument.fromJson(jsonDecode(contents));
  }

  // 3. 저장
  static Future<void> saveNote(Note note, NotusDocument document) async {
    await NotesApi.updateNote(note.title, lastOpenFileName);
    await ZefyrApi.updateDocument(document, lastOpenFilePath);
  }

  // 4. 세팅 문서 업데이트
  static Future<void> updateLastNote(String fileName) async {
    await SettingsApi.updateLastOpenNoteName(fileName);
  }

  // 5. 문서 삭제
  static Future<void> deleteNote(String fileName) async {
    if (SettingsApi.settingsModel.lastOpenNoteName == fileName) {
      // 현재 문서가 삭제되면, 텅비워줌.
      await SettingsApi.updateLastOpenNoteName('empty');
    }
    final Note note = await NotesApi.getNoteByName(fileName);
    await NotesApi.deleteNote(note);
    await ZefyrApi.deleteDocument(
        SettingsApi.settingsModel.rootPath + '/note-data/json/$fileName.json');
  }

  // 6. 문서 생성
  static Future<void> addNote(int parentKey) async {
    final document = await ZefyrApi.stringToDocument('아무내용도 없을때는 어떻게 해야함?\n');
    final title = '제목없음';

    final newFileName = DateTime.now().toIso8601String();
    final newFilePath =
        SettingsApi.settingsModel.rootPath + '/note-data/json/$newFileName.json';

    await ZefyrApi.addDocument(document, newFilePath);
    await NotesApi.addNote(title, newFileName, parentKey);
  }
}
