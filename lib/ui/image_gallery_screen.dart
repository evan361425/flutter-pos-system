import 'dart:io';

import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/xfile.dart';
import 'package:possystem/services/image_dumper.dart';
import 'package:possystem/translator.dart';

class ImageGalleryScreen extends StatefulWidget {
  const ImageGalleryScreen({Key? key}) : super(key: key);

  @override
  State<ImageGalleryScreen> createState() => ImageGalleryScreenState();
}

class ImageGalleryScreenState extends State<ImageGalleryScreen> {
  List<String>? images;

  bool isSelecting = false;

  final Set<int> selectedImages = {};

  late Directory baseDir;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isSelecting) {
          cancelSelecting();
          return false;
        }
        return true;
      },
      child: SafeArea(
        child: isSelecting ? buildSelectingScaffold() : buildScaffold(),
      ),
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
        leading: IconButton(
          key: const Key('image_gallery.cancel'),
          onPressed: cancelSelecting,
          icon: const Icon(Icons.close_sharp),
        ),
        actions: [
          TextButton(
            key: const Key('image_gallery.delete'),
            onPressed: () {
              DeleteDialog.show(
                context,
                warningContent: Text('將會刪除 ${selectedImages.length} 個圖片\n'
                    '刪除之後會讓相關產品顯示不到圖片'),
                finishMessage: false,
                deleteCallback: deleteImages,
              );
            },
            child: Text(S.btnDelete),
          ),
        ],
        title: const Text('刪除所選'),
      ),
      body: buildBody(),
    );
  }

  Widget buildScaffold() {
    return Scaffold(
      appBar: AppBar(
        leading: const PopButton(),
        title: const Text('圖片管理'),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('image_gallery.add'),
        onPressed: createImage,
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
          tooltip: '點擊開始匯入你的第一張照片！',
        ),
      );
    }

    return GridView.builder(
      primary: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: images!.length,
      semanticChildCount: images!.length,
      itemBuilder: (context, index) {
        final image = XFile(images![index]);

        final inkwell = isSelecting
            ? Material(
                color: Colors.black.withAlpha(100),
                child: Checkbox(
                  value: selectedImages.contains(index),
                  onChanged: (bool? value) {
                    setState(() {
                      value == true
                          ? selectedImages.add(index)
                          : selectedImages.remove(index);
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

      final imageList = await baseDir
          .list()
          .map((e) => e.path)
          .where((e) => !e.endsWith('-avator'))
          .toList();
      // 因為照著時間產生的在最後面，但他應該在最前面，所以反序排列。
      // 除此之外，最新的圖片應該在最上面。
      imageList.sort((a, b) => a.compareTo(b) * -1);
      setState(() => images = imageList);
    }
  }

  void createImage() async {
    final image = await ImageDumper.instance.pick();

    if (image != null) {
      // 2023-01-01T01:23:45.123
      // G20230101T012345123
      final name = DateTime.now()
          .toIso8601String()
          .replaceAll('-', '')
          .replaceAll(':', '')
          .replaceFirst('.', '');
      // 原本檔名是 uuid v4 產生，前綴為 [0-9A-F]，
      // 為了做區別而設計成這樣。
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
      Navigator.of(context).pop(image);
    }
  }

  Future<void> deleteImages() async {
    final target = selectedImages.expand((index) {
      return [XFile(images![index]), XFile('${images![index]}-avator')];
    }).toList();

    cancelSelecting(reloadImages: true);

    try {
      await Future.wait(target.map((image) => image.file.delete()));

      if (context.mounted) {
        showSnackBar(context, S.actSuccess);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, '有一個或多個圖片沒有刪成功。');
      }
      Log.out(e.toString(), 'delete_image_error');
    } finally {
      prepareImages();
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
