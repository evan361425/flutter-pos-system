import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/xfile.dart';
import 'package:possystem/services/image_dumper.dart';

class ImageHolder extends StatefulWidget {
  final ImageProvider image;

  final String title;

  final void Function()? onPressed;

  final FocusNode? focusNode;

  final EdgeInsets padding;

  const ImageHolder({
    Key? key,
    required this.image,
    required this.title,
    this.onPressed,
    this.focusNode,
    this.padding = const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 8.0),
  }) : super(key: key);

  @override
  State<ImageHolder> createState() => _ImageHolderState();
}

class _ImageHolderState extends State<ImageHolder> {
  late ImageProvider image;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.background;
    final textColor = Theme.of(context).textTheme.bodyMedium!.color;
    final colors = [color, color.withAlpha(180), color.withAlpha(10)];

    Widget body = Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 512, maxWidth: 512),
      decoration: const BoxDecoration(border: Border()),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          padding: widget.padding,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors[0])),
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: Text(widget.title, textAlign: TextAlign.center),
        ),
      ),
    );

    if (widget.onPressed != null) {
      body = InkWell(
        onTap: widget.onPressed,
        focusNode: widget.focusNode,
        child: body,
      );
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Ink.image(
        padding: EdgeInsets.zero,
        image: widget.image,
        fit: BoxFit.cover,
        onImageError: (error, stack) {
          Log.err(error, 'image_holder_error', stack);
          setState(() {
            image = const AssetImage("assets/food_placeholder.png");
          });
        },
        child: Material(
          type: MaterialType.transparency,
          textStyle: TextStyle(color: textColor),
          child: body,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    image = widget.image;
  }
}

class EditImageHolder extends StatelessWidget {
  final String? path;

  final void Function(String) onSelected;

  const EditImageHolder({
    Key? key,
    this.path,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ImageProvider image = path == null
        ? const AssetImage("assets/food_placeholder.png") as ImageProvider
        : FileImage(XFile(path!).file);

    return ImageHolder(
      key: const Key('image_holder.edit'),
      image: image,
      title: path == null ? '點選以新增圖片' : '點擊以更新圖片',
      onPressed: () async {
        final image = await ImageDumper.instance.pick();
        if (image != null) onSelected(image.path);
      },
    );
  }
}
