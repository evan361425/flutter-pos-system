import 'dart:io';

class ImageFile {
  final File? _file;

  final String? _path;

  const ImageFile({File? file, String? path})
      : _file = file,
        _path = path;

  File get file => _file ?? File(_path!);

  String? get path => _path ?? _file?.path;

  Future<ImageFile> copy(String newPath) async => ImageFile(
        file: await file.copy(newPath),
      );
}
