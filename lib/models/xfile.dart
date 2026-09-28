import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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

  static Future<Directory> getDir(String path) async {
    final dir = await XFile.getRootPath();
    final Directory baseDir = XFile(XFile.fs.path.join(dir, path)).dir;

    await baseDir.create();

    return baseDir;
  }

  static Future<List<int>?> pick() async {
    final result = await FilePicker.platform.pickFiles(withReadStream: true, type: .any);
    final file = result?.files.firstOrNull;
    Log.out('picked file: ${file?.path}', 'file');

    final data = await file?.readStream?.toList();
    return data?.reduce((a, b) => a + b);
  }

  static Future<bool> save({required String dialogTitle, required String fileName, required Uint8List bytes}) async {
    final path = await FilePicker.platform.saveFile(dialogTitle: dialogTitle, fileName: fileName, bytes: bytes);
    Log.out('saved $fileName to $path', 'file');

    // web will always return null
    if (path == null && !kIsWeb) {
      return false;
    }

    return true;
  }

  /// 2023-01-01T01:23:45.123
  /// 20230101T012345123
  static String timestampFilename({required String folder, String prefix = '', String suffix = ''}) {
    final name = DateTime.now().toIso8601String().replaceAll('-', '').replaceAll(':', '').replaceFirst('.', '');
    return XFile.fs.path.join(folder, '$prefix$name$suffix');
  }
}
