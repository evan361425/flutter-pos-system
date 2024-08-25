import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/xfile.dart';
import 'package:possystem/services/image_dumper.dart';
import 'package:possystem/translator.dart';

class ImageGalleryPage extends StatefulWidget {
  const ImageGalleryPage({super.key});

  @override
  State<ImageGalleryPage> createState() => ImageGalleryPageState();
}

class ImageGalleryPageState extends State<ImageGalleryPage> {
  List<String>? images;

  bool isSelecting = false;

  final Set<int> selectedImages = {};

  late Directory baseDir;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isSelecting,
      onPopInvoked: onPopInvoked,
      child: isSelecting ? buildSelectingScaffold() : buildScaffold(),
    );
  }

  @override
  void initState() {
    super.initState();
    prepareImages();
  }

  Widget buildSelectingScaffold() {
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(
          key: const Key('image_gallery.cancel'),
          onPressed: () => onPopInvoked(false),
        ),
        actions: [
          TextButton(
            key: const Key('image_gallery.delete'),
            onPressed: () {
              DeleteDialog.show(
                context,
                warningContent: Text(S.imageGallerySelectionDeleteConfirm(selectedImages.length)),
                finishMessage: false,
                deleteCallback: deleteImages,
              );
            },
            child: Text(S.imageGalleryActionDelete),
          ),
        ],
        title: Text(S.imageGallerySelectionTitle),
      ),
      body: buildBody(),
    );
  }

  Widget buildScaffold() {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(S.imageGalleryTitle),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('image_gallery.add'),
        onPressed: createImage,
        tooltip: S.imageGalleryActionCreate,
        child: const Icon(KIcons.add),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (images == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (images!.isEmpty) {
      return Center(
        child: EmptyBody(
          onPressed: createImage,
          content: S.imageGalleryEmpty,
        ),
      );
    }

    final crossAxisCount = Breakpoint.find(width: MediaQuery.sizeOf(context).width).lookup<int>(
      compact: 2,
      medium: 3,
      large: 4,
    );
    return GridView.builder(
      primary: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: images!.length + crossAxisCount,
      semanticChildCount: images!.length,
      itemBuilder: (context, index) {
        if (index >= images!.length) {
          // Floating action button offset
          return const SizedBox(height: 72.0);
        }
        final image = XFile(images![index]);

        final inkwell = isSelecting
            ? Material(
                color: Colors.black.withAlpha(100),
                child: Checkbox(
                  value: selectedImages.contains(index),
                  onChanged: (bool? value) {
                    setState(() {
                      value == true ? selectedImages.add(index) : selectedImages.remove(index);
                    });
                  },
                ),
              )
            : InkWell(
                onTap: () => pickImage(image.path),
                onLongPress: () => startSelecting(index),
                child: const SizedBox.expand(),
              );

        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 512, maxWidth: 512),
          decoration: const BoxDecoration(border: Border()),
          child: Ink.image(
            padding: EdgeInsets.zero,
            image: FileImage(image.file),
            fit: BoxFit.cover,
            child: Material(
              key: Key('image_gallery.$index'),
              type: MaterialType.transparency,
              child: inkwell,
            ),
          ),
        );
      },
      restorationId: 'image_gallery',
    );
  }

  void prepareImages() async {
    if (context.mounted) {
      final dir = await XFile.getRootPath();
      baseDir = XFile(XFile.fs.path.join(dir, 'menu_image')).dir;

      await baseDir.create();

      final imageList = await baseDir.list().map((e) => e.path).where((e) => !e.endsWith('-avator')).toList();
      // Because the image is generated by time, it should be at the front,
      // so reverse the order.
      // In another word, the newest image should be at the top.
      imageList.sort((a, b) => a.compareTo(b) * -1);
      setState(() => images = imageList);
    }
  }

  void createImage() async {
    final image = await ImageDumper.instance.pick();

    if (image != null) {
      // 2023-01-01T01:23:45.123
      // 20230101T012345123
      final name = DateTime.now().toIso8601String().replaceAll('-', '').replaceAll(':', '').replaceFirst('.', '');
      // Default name is uuid v4, prefix with [0-9A-F]
      // to avoid conflict with origin one we add 'g' prefix
      final dst = XFile.fs.path.join(baseDir.path, 'g$name');
      Log.ger('save_image', 'start', dst);

      // avator first, avoid different with origin one
      await ImageDumper.instance.resize(image, '$dst-avator', width: 120);

      // save image from pick
      await image.copy(dst);

      pickImage(dst);
    }
  }

  void pickImage(String? image) {
    if (context.mounted) {
      context.pop(image);
    }
  }

  Future<void> deleteImages() async {
    final target = selectedImages.expand((index) {
      return [XFile(images![index]), XFile('${images![index]}-avator')];
    }).toList();

    cancelSelecting(reloadImages: true);

    try {
      await Future.wait(target.map((image) => image.file.delete()));

      if (mounted) {
        showSnackBar(context, S.actSuccess);
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, S.imageGallerySnackbarDeleteFailed);
      }
      Log.out(e.toString(), 'delete_image_error');
    } finally {
      prepareImages();
    }
  }

  void onPopInvoked(bool didPop) {
    if (!didPop) {
      cancelSelecting();
    }
  }

  void cancelSelecting({reloadImages = false}) {
    setState(() {
      if (reloadImages) images = null;
      isSelecting = false;
    });
  }

  void startSelecting(int index) {
    setState(() {
      selectedImages.clear();
      selectedImages.add(index);
      isSelecting = true;
    });
  }
}
