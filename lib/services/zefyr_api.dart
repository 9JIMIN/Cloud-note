import 'dart:convert';
import 'dart:io';

import 'package:zefyr/zefyr.dart';
import 'package:quill_delta/quill_delta.dart';

class ZefyrApi {
  static Future<NotusDocument> stringToDocument(String string) async {
    final Delta delta = Delta()..insert("$string\n");
    return NotusDocument.fromDelta(delta);
  }

  static Future<void> addDocument(
      NotusDocument document, String filePath) async {
    final contents = jsonEncode(document);
    File(filePath).create(recursive: true).then((File file) async {
      await file.writeAsString(contents);
      print('addDocument: ' + filePath);
    });
  }

  static Future<void> updateDocument(
      NotusDocument document, String filePath) async {
    final contents = jsonEncode(document);
    await File(filePath).writeAsString(contents);
  }

  static Future<NotusDocument> readFile(String filePath) async {
    final contents = await File(filePath).readAsString();
    return NotusDocument.fromJson(jsonDecode(contents));
  }
  
  static Future<void> deleteDocument(String filePath) async {
    await File(filePath).delete(recursive: true);
  }
}
