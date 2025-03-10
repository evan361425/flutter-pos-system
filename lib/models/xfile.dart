import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:possystem/helpers/logger.dart';

class XFile {
  static FileSystem fs = const LocalFileSystem();

  final String path;

  const XFile(this.path);

  Directory get dir => fs.directory(path);

  File get file => fs.file(path);

  Future<File> copy(String newPath) => file.copy(newPath);

  static Future<Directory> createDir(String folder) async {
    final directory = await getRootPath();

    final path = fs.path.join(directory, folder);

    return XFile(path).dir.create();
  }

  static Future<String> getRootPath() async {
    return fs is LocalFileSystem ? (await getApplicationDocumentsDirectory()).path : '';
  }

  static Future<List<int>?> pick() async {
    final file = await FilePicker.platform.pickFiles(
      withReadStream: true,
      type: FileType.any,
    );

    final data = await file?.files.firstOrNull?.readStream?.toList();
    return data?.reduce((a, b) => a + b);
  }

  static Future<bool> save({
    required List<Uint8List> bytes,
    required List<String> fileNames,
    required String dialogTitle,
  }) async {
    assert(bytes.length == fileNames.length, 'bytes and fileNames length not match');
    final path = await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileNames[0],
      bytes: bytes[0],
    );
    Log.out('save file to $path', 'file');

    if (path == null) {
      return false;
    }

    final file = XFile(path).file;
    if (!(await file.exists())) {
      // in desktop platform, the file is not created
      await file.writeAsBytes(bytes[0]);
    }

    final dir = file.parent;
    for (var i = 1; i < bytes.length; i++) {
      await dir.childFile(fileNames[i]).writeAsBytes(bytes[i]);
    }

    return true;
  }
}
