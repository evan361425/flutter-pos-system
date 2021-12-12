import 'package:image/image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart' hide XFile;
import 'package:possystem/models/xfile.dart';

class ImageDumper {
  static ImageDumper instance = const ImageDumper._();

  const ImageDumper._();

  /// After pick, it is always JPEG image
  Future<XFile?> pick() async {
    // Pick an image
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image == null) return null;

    final result = await ImageCropper.cropImage(
      sourcePath: image.path,
      maxHeight: 512,
      maxWidth: 512,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      androidUiSettings: const AndroidUiSettings(toolbarTitle: '裁切'),
    );

    return result == null ? null : XFile(result.path);
  }

  Future<XFile?> resize(
    XFile image,
    String destination, {
    int? width,
    int? height,
  }) async {
    final decodedImage = decodeImage(await image.file.readAsBytes());
    if (decodedImage == null) return null;

    final dst = XFile(destination);

    await dst.file.writeAsBytes(encodeJpg(copyResize(
      decodedImage,
      width: width,
      height: height,
    )));

    return dst;
  }
}
