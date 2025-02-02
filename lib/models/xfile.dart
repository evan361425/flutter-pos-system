import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

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

  static Future<Stream<List<int>>?> pick({
    required List<String> extensions,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      withReadStream: true,
      allowedExtensions: extensions,
      type: FileType.custom,
    );

    return result?.files.firstOrNull?.readStream;
  }
}
