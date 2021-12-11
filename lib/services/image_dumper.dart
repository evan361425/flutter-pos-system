import 'dart:io';

import 'package:image/image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageDumper {
  static ImageDumper instance = const ImageDumper._();

  const ImageDumper._();

  /// After pick, it is always JPEG image
  Future<File?> pick() async {
    final picker = ImagePicker();
    // Pick an image
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return null;

    return await ImageCropper.cropImage(
      sourcePath: image.path,
      maxHeight: 512,
      maxWidth: 512,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      androidUiSettings: const AndroidUiSettings(toolbarTitle: '裁切'),
    );
  }

  Future<Image?> resize(
    File image, {
    int? width,
    int? height,
  }) async {
    final decodedImage = decodeImage(await image.readAsBytes());
    if (decodedImage == null) return null;

    return copyResize(
      decodedImage,
      width: width,
      height: height,
    );
  }

  Future<File> toPNG(Image image, String path) {
    return File(path).writeAsBytes(encodePng(image));
  }
}
