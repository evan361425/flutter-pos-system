import 'dart:io';

import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/image_file.dart';
import 'package:possystem/models/model_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/services/database.dart';
import 'package:possystem/services/image_dumper.dart';
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
  @override
  String get logName => modelTableName;

  String get modelTableName;

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

mixin ModelImage<T extends ModelObject> on Model<T> {
  String? imagePath;

  Widget get avator {
    if (imagePath == null) {
      return CircleAvatar(
        child: Text(name.characters.first.toUpperCase()),
      );
    }

    final image = FileImage(File(_avatorPath));
    return CircleAvatar(foregroundImage: image);
  }

  ImageProvider get image {
    if (imagePath == null) {
      return const AssetImage("assets/food_placeholder.png");
    }

    return FileImage(File(imagePath!));
  }

  String get _avatorPath => '$imagePath-avator';

  Future<void> pickImage() async {
    final image = await ImageDumper.instance.pick();
    if (image == null) return;

    await saveImage(image);
  }

  Future<void> replaceImage(ImageFile image) async {
    if (image.path != null && image.path != imagePath) {
      await saveImage(image);
    }
  }

  Future<void> saveImage(ImageFile image) async {
    final path = await ImageDumper.instance.getPath('menu_image');
    final dstPath = '$path/$id';

    // avator first, try sync with image
    await ImageDumper.instance.resize(image, '$dstPath-avator', width: 120);

    // save image from pick
    await image.copy(dstPath);

    info(toString(), '$logName.updateImage');

    await save({'$prefix.imagePath': dstPath});

    if (imagePath != null) {
      await ImageDumper.instance.deletePath(imagePath!);
      await ImageDumper.instance.deletePath(_avatorPath);
    }

    imagePath = dstPath;

    notifyItem();
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
  @override
  String get logName => storageStore.toString();

  Stores get storageStore;

  @override
  Future<void> removeRemotely() {
    return save({prefix: null});
  }

  @override
  Future<void> save(Map<String, Object?> data) {
    return Storage.instance.set(storageStore, data);
  }
}
