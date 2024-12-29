import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/model_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/xfile.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/storage.dart';

enum ModelStatus {
  normal,
  staged,
  updated,
}

abstract class Model<T extends ModelObject> extends ChangeNotifier {
  final String id;

  String name;

  /// Whether the data is saved in the file system, only exists in memory.
  ///
  /// This is used to import/export data.
  ModelStatus status;

  Model({
    String? id,
    required this.name,
    required this.status,
  }) : id = id ?? Util.uuidV4();

  String get logName;

  String get prefix => id;

  String get statusName => status.name;

  Repository<Model<T>> get repository;

  set repository(Repository repo) {}

  void notifyItem() {
    notifyListeners();
    repository.notifyItems();
  }

  Future<void> remove() async {
    Log.ger('remove_item', {'type': logName, 'name': toString()});

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

    Log.ger('update_item', {'type': logName, 'name': toString()});

    await save(updateData);

    notifyItem();
  }
}

mixin ModelImage<T extends ModelObject> on Model<T> {
  String? imagePath;

  bool _avatorMissed = false;

  bool get useDefaultImage => imagePath == null;

  Widget get avator {
    if (useDefaultImage || _avatorMissed) {
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
    if (useDefaultImage) {
      return const AssetImage("assets/food_placeholder.png");
    }

    return FileImage(XFile(imagePath!).file);
  }

  String get _avatorPath => '$imagePath-avator';

  Future<void> pickImage(BuildContext context) async {
    final image = await context.pushNamed(Routes.imageGallery);
    if (image != null && image is String && image != imagePath) {
      saveImage(image);
    }
  }

  Future<void> saveImage(String? image) async {
    Log.ger('update_item_image', {'type': logName, 'name': toString()});
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

    pattern.split(' ');

    int score = 0;
    for (final p in pattern.split(' ').map((e) => e.trim()).where((e) => e.isNotEmpty)) {
      score += name.split(' ').fold<int>(0, (value, e) {
        final addition = e.startsWith(p)
            ? 2
            : e.contains(p)
                ? 1
                : 0;
        return value + addition;
      });
    }

    return score + (name == pattern ? 999 : 0);
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
