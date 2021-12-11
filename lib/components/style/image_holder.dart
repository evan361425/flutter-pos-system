import 'dart:io';

import 'package:flutter/material.dart';
import 'package:possystem/models/image_file.dart';
import 'package:possystem/services/image_dumper.dart';

class ImageHolder extends StatelessWidget {
  final String? path;

  final void Function(ImageFile) onSelected;

  const ImageHolder({
    Key? key,
    this.path,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (path == null) {
      return InkWell(
        key: const Key('modal.add_image'),
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: const BorderRadius.all(Radius.circular(4.0)),
            ),
            child: const Center(
              child: Text('點選以新增圖片'),
            ),
          ),
        ),
      );
    }

    final color = Theme.of(context).scaffoldBackgroundColor;
    final title = Container(
      padding: const EdgeInsets.fromLTRB(2, 8, 2, 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            color,
            color.withAlpha(200),
            color.withAlpha(0),
          ],
        ),
      ),
      child: const Text(
        '點擊以更新圖片',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18.0),
      ),
    );

    return GestureDetector(
      key: const Key('modal.edit_image'),
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Image(
            image: FileImage(File(path!)),
            fit: BoxFit.cover,
            width: double.infinity,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[Expanded(child: title)],
          ),
        ],
      ),
    );
  }

  void onTap() async {
    final image = await ImageDumper.instance.pick();

    if (image != null) onSelected(image);
  }
}
