import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/model_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/services/database.dart';
import 'package:possystem/services/storage.dart';

abstract class Model<T extends ModelObject> extends ChangeNotifier {
  late String id;

  late String name;

  Model(String? id) : id = id ?? Util.uuidV4();

  String get logName;

  String get prefix => id;

  Repository<Model<T>> get repository;

  set repository(Repository repo);

  void notifyItem() {
    notifyListeners();
    repository.notifyItems();
  }

  Future<void> remove() async {
    info(toString(), '$logName.remove');

    await removeRemotely();

    repository.removeItem(id);
  }

  Future<void> removeRemotely();

  Future<void> save(Map<String, Object?> data);

  T toObject();

  @override
  String toString() => name;

  /// Return `true` if updated any field
  Future<void> update(T object, {String event = 'update'}) async {
    final updateData = object.diff(this);

    if (updateData.isEmpty) return;

    info(toString(), '$logName.$event');

    await save(updateData);

    notifyItem();
  }
}

mixin ModelDB<T extends ModelObject> on Model<T> {
  String get modelTableName;

  @override
  String get logName => modelTableName;

  @override
  Future<void> removeRemotely() {
    return Database.instance.update(modelTableName, int.parse(id), {
      'isDelete': 1,
    });
  }

  @override
  Future<void> save(Map<String, Object?> data) {
    return Database.instance.update(modelTableName, int.parse(id), data);
  }
}

mixin ModelOrderable<T extends ModelObject> on Model<T> {
  late int index;
}

mixin ModelSearchable<T extends ModelObject> on Model<T> {
  /// get similarity between [name] and [pattern]
  int getSimilarity(String pattern) {
    final name = this.name.toLowerCase();
    pattern = pattern.toLowerCase();

    final score = name.split(' ').fold<int>(0, (value, e) {
      final addition = e.startsWith(pattern)
          ? 2
          : e.contains(pattern)
              ? 1
              : 0;
      return value + addition;
    });

    return score;
  }
}

mixin ModelStorage<T extends ModelObject> on Model<T> {
  Stores get storageStore;

  @override
  String get logName => storageStore.toString();

  @override
  Future<void> removeRemotely() {
    return save({prefix: null});
  }

  @override
  Future<void> save(Map<String, Object?> data) {
    return Storage.instance.set(storageStore, data);
  }
}

mixin ModelImage<T extends ModelObject> on Model<T> {
  String? imagePath;

  ImageProvider get image {
    if (imagePath == null) {
      return const AssetImage("assets/food_placeholder.png");
    }

    return FileImage(File(imagePath!));
  }

  Widget get avator {
    if (imagePath == null) {
      return CircleAvatar(
        child: Text(name.characters.first.toUpperCase()),
      );
    }

    final image = FileImage(File('$imagePath-avator'));
    return CircleAvatar(foregroundImage: image);
  }

  Future<void> pickImage() async {
    final newPath = await uploadNewImage();

    if (newPath != null) {
      replaceImage(newPath);
    }
  }

  Future<void> replaceImage(String newPath) async {
    info(toString(), '$logName.updateImage');

    await save({'$prefix.imagePath': newPath});

    if (imagePath != null) {
      await File(imagePath!).delete();
      await File('$imagePath-avator').delete();
    }

    imagePath = newPath;

    notifyItem();
  }

  Future<String?> uploadNewImage() async {
    final picker = ImagePicker();
    // Pick an image
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return null;

    final croppedFile = await ImageCropper.cropImage(
      sourcePath: image.path,
      maxHeight: 512,
      maxWidth: 512,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      androidUiSettings: const AndroidUiSettings(toolbarTitle: '裁切'),
    );

    if (croppedFile == null) return null;

    final path = await _getImagePath();
    final dstPath = '$path/${Util.uuidV4()}';

    // Resize first to avoid undecodable file
    final decodedImage = decodeImage(await croppedFile.readAsBytes());
    // CircularAvator defalut size: [40, 40]
    final avator = encodePng(copyResize(decodedImage!, width: 120));
    await File('$dstPath-avator').writeAsBytes(avator);

    // copy the file to a new path
    await croppedFile.copy(dstPath);

    return dstPath;
  }

  Future<String> _getImagePath() async {
    final directory = await getApplicationDocumentsDirectory();

    final path = '${directory.path}/menu_image';

    await Directory(path).create();

    return path;
  }
}
