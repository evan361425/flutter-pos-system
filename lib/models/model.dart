import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/model_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/xfile.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/database.dart';
import 'package:possystem/services/storage.dart';

enum ModelStatus {
  normal,
  staged,
  updated,
}

abstract class Model<T extends ModelObject> extends ChangeNotifier {
  late String id;

  late String name;

  // 是否是暫存的資料，並未存進檔案系統中，僅存在於記憶體中。
  late ModelStatus status;

  Model(String? id, ModelStatus? status)
      : id = id ?? Util.uuidV4(),
        status = status ?? ModelStatus.normal;

  String get logName;

  String get prefix => id;

  String get statusName => status.name;

  Repository<Model<T>> get repository;

  set repository(Repository repo);

  void notifyItem() {
    notifyListeners();
    repository.notifyItems();
  }

  Future<void> remove() async {
    Log.ger('remove start', logName, toString());

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

    Log.ger('$event start', logName, toString());

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

  bool _avatorMissed = false;

  Widget get avator {
    if (imagePath == null || _avatorMissed) {
      return CircleAvatar(
        child: Text(name.characters.first.toUpperCase()),
      );
    }

    final image = FileImage(XFile(_avatorPath).file);
    return CircleAvatar(
        foregroundImage: image,
        onForegroundImageError: (err, stack) {
          _avatorMissed = true;
        });
  }

  ImageProvider get image {
    if (imagePath == null) {
      return const AssetImage("assets/food_placeholder.png");
    }

    return FileImage(XFile(imagePath!).file);
  }

  String get _avatorPath => '$imagePath-avator';

  Future<void> pickImage(BuildContext context) async {
    final image = await Navigator.of(context).pushNamed(Routes.imageGallery);
    if (image != null && image is String && image != imagePath) {
      saveImage(image);
    }
  }

  Future<void> saveImage(String? image) async {
    Log.ger('save_image', logName, toString());
    await save({'$prefix.imagePath': image});

    imagePath = image;

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
  String get logName => storageStore.name;

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
