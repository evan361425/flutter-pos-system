import 'package:flutter/material.dart';
import 'package:possystem/models/xfile.dart';
import 'package:possystem/services/image_dumper.dart';

class ImageHolder extends StatelessWidget {
  final String? path;

  final void Function(String) onSelected;

  final FocusNode? focusNode;

  const ImageHolder({
    Key? key,
    this.path,
    this.focusNode,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = path == null ? '點選以新增圖片' : '點擊以更新圖片';
    final image = path == null
        ? const AssetImage("assets/food_placeholder.png")
        : FileImage(XFile(path!).file);

    return InkWell(
      key: const Key('modal.edit_image'),
      onTap: onTap,
      focusNode: focusNode,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Image(
            image: image as ImageProvider,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, err, stack) {
              return const Image(
                key: Key('image_holder.missed'),
                image: AssetImage("assets/food_placeholder.png"),
                fit: BoxFit.cover,
                width: double.infinity,
              );
            },
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(child: _GradientTitle(title)),
            ],
          ),
        ],
      ),
    );
  }

  void onTap() async {
    final image = await ImageDumper.instance.pick();

    if (image != null) onSelected(image.path);
  }
}

class _GradientTitle extends StatelessWidget {
  final String text;

  const _GradientTitle(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).scaffoldBackgroundColor;
    return Container(
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
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18.0),
      ),
    );
  }
}
