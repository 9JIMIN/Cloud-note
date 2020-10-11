import 'package:flutter_archive/flutter_archive.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import 'dart:io';
import 'dart:convert';

import 'google_auth_client.dart';

class GoogleDrive {
  static Future<void> uploadFile(String rootPath) async {
    final googleSignIn = GoogleSignIn(scopes: [drive.DriveApi.DriveScope]);
    final GoogleSignInAccount account = await googleSignIn.signIn();

    final authHeaders = await account.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);

    // final Stream<List<int>> mediaStream =
    //     Future.value([104, 105]).asStream().asBroadcastStream();
    // var media = Media(mediaStream, 2);
    // var driveFile = File();
    // driveFile.name = "hello_world.txt";

    // 파일 처리
    await File(rootPath + '/note-data/settings.hive').create(recursive: true);
    await File(rootPath + '/note-data/notes.hive').create(recursive: true);
    await File(rootPath + '/settings.hive')
        .copy(rootPath + '/note-data/settings.hive');
    await File(rootPath + '/notes.hive')
        .copy(rootPath + '/note-data/notes.hive');

    final dataDir = Directory(rootPath + '/note-data');

    final File zipFile = File(rootPath + '/note-backup.zip');
    await ZipFile.createFromDirectory(
      sourceDir: dataDir,
      zipFile: zipFile,
      recurseSubDirs: true,
    );

    drive.File driveFile = drive.File();
    driveFile.name = 'note-backup.zip';
    final drive.Media media = drive.Media(
      zipFile.openRead(),
      zipFile.lengthSync(),
    );

    final result = await driveApi.files.create(driveFile, uploadMedia: media);
    print("Upload result: $result");
  }

  static Future<void> extractFile() async {}
}
