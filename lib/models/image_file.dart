import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart';

class ImageFile {
  final Image? _image;

  final File? _file;

  final String? _path;

  const ImageFile({Image? image, File? file, String? path})
      : _image = image,
        _file = file,
        _path = path;

  File get file => _file ?? File(_path!);

  String? get path => _path ?? _file?.path;

  Future<Uint8List> fileReadAsBytes() => file.readAsBytes();

  Future<ImageFile> fileCopy(String newPath) async => ImageFile(
        file: await file.copy(newPath),
      );

  Future<ImageFile> toPNG(String path) async => ImageFile(
        file: await File(path).writeAsBytes(encodePng(_image!)),
      );
}
