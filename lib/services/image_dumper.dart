import 'dart:io';

import 'package:image/image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:possystem/models/image_file.dart';

class ImageDumper {
  static ImageDumper instance = const ImageDumper._();

  const ImageDumper._();

  /// After pick, it is always JPEG image
  Future<ImageFile?> pick() async {
    final picker = ImagePicker();
    // Pick an image
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return null;

    final file = await ImageCropper.cropImage(
      sourcePath: image.path,
      maxHeight: 512,
      maxWidth: 512,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      androidUiSettings: const AndroidUiSettings(toolbarTitle: '裁切'),
    );

    return ImageFile(file: file);
  }

  Future<ImageFile?> resize(
    ImageFile image, {
    int? width,
    int? height,
  }) async {
    final decodedImage = decodeImage(await image.fileReadAsBytes());
    if (decodedImage == null) return null;

    final result = copyResize(
      decodedImage,
      width: width,
      height: height,
    );
    ImageFile(image: result);
  }

  Future<String> getPath(String folder) async {
    final directory = await getApplicationDocumentsDirectory();

    final path = '${directory.path}/$folder';

    await Directory(path).create();

    return path;
  }

  Future<void> deletePath(String path) {
    return File(path).delete();
  }
}
