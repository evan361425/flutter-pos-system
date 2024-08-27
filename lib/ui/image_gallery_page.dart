import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/constant.dart';
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

  bool selecting = false;

  final Set<int> selectedImages = {};

  late Directory baseDir;

  @override
  Widget build(BuildContext context) {
    final bp = Breakpoint.find(width: MediaQuery.sizeOf(context).width);
    final fullScreen = bp <= Breakpoint.medium;

    final PreferredSizeWidget? appBar = selecting
        ? AppBar(
            title: Text(S.imageGallerySelectionTitle),
            primary: false,
            leading: IconButton(
              key: const Key('image_gallery.cancel'),
              onPressed: () => onPopInvoked(false),
              icon: const Icon(Icons.cancel),
            ),
            actions: [
              TextButton(
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
          )
        : fullScreen
            ? AppBar(
                title: Text(S.imageGalleryTitle),
                primary: false,
                leading: const CloseButton(key: Key('image_gallery.close')),
              )
            : null;

    final body = Scaffold(
      primary: false,
      appBar: appBar,
      body: Padding(
        padding: fullScreen ? const EdgeInsets.symmetric(horizontal: kHorizontalSpacing) : EdgeInsets.zero,
        child: _buildBody(bp),
      ),
    );

    return PopScope(
      canPop: !selecting,
      onPopInvoked: onPopInvoked,
      child: fullScreen
          ? Dialog.fullscreen(child: body)
          : AlertDialog(
              contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              scrollable: false,
              title: appBar == null ? Text(S.imageGalleryTitle) : null,
              content: Center(child: SizedBox(width: 600, child: body)),
            ),
    );
  }

  Widget _buildBody(Breakpoint bp) {
    if (images == null) {
      return const SingleChildScrollView(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (images!.isEmpty) {
      return SingleChildScrollView(
        child: Center(
          child: EmptyBody(
            onPressed: createImage,
            content: S.imageGalleryEmpty,
          ),
        ),
      );
    }

    final spacing = bp.lookup(compact: 4.0, expanded: 12.0);
    return GridView.builder(
      primary: false,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: bp.lookup(compact: 3, expanded: 4, large: 5),
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      // add 1 for add button, add crossAxisCount for spacing
      itemCount: images!.length + (selecting ? 0 : 1) + 3,
      semanticChildCount: images!.length,
      itemBuilder: (context, index) {
        if (!selecting && index == images!.length) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              key: const Key('image_gallery.add'),
              onPressed: createImage,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(KIcons.add),
                Text(S.imageGalleryActionCreate, textAlign: TextAlign.center),
              ]),
            ),
          );
        }

        if (index >= images!.length) {
          // Floating action button offset
          return const SizedBox(height: kFABSpacing);
        }

        final image = XFile(images![index]);
        final inkwell = selecting
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

        return Ink.image(
          image: FileImage(image.file),
          fit: BoxFit.cover,
          child: Material(
            key: Key('image_gallery.$index'),
            type: MaterialType.transparency,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: inkwell,
          ),
        );
      },
      restorationId: 'image_gallery',
    );
  }

  @override
  void initState() {
    super.initState();
    _prepareImages();
  }

  void _prepareImages() async {
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
      _prepareImages();
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
      selecting = false;
    });
  }

  void startSelecting(int index) {
    setState(() {
      selectedImages.clear();
      selectedImages.add(index);
      selecting = true;
    });
  }
}
