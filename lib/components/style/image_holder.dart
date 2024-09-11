import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/xfile.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class ImageHolder extends StatelessWidget {
  final ImageProvider image;

  final String? title;

  final void Function()? onPressed;

  final void Function()? onImageError;

  final FocusNode? focusNode;

  final EdgeInsets padding;

  final double size;

  const ImageHolder({
    super.key,
    required this.image,
    this.title,
    this.size = 256,
    this.onPressed,
    this.onImageError,
    this.focusNode,
    this.padding = const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 8.0),
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surface;
    final style = Theme.of(context).textTheme.bodyMedium;
    final colors = [color, color.withAlpha(180), color.withAlpha(10)];

    Widget body = title == null
        ? const SizedBox.expand()
        : Container(
            width: double.infinity,
            decoration: const BoxDecoration(border: Border()),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: padding,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: colors[0])),
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: style?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );

    if (onPressed != null) {
      body = InkWell(
        onTap: onPressed,
        focusNode: focusNode,
        child: body,
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: size, maxWidth: size),
      child: AspectRatio(
        aspectRatio: 1,
        child: Material(
          type: MaterialType.transparency,
          textStyle: TextStyle(color: style?.color),
          child: Ink.image(
            padding: EdgeInsets.zero,
            image: image,
            fit: BoxFit.cover,
            onImageError: (error, stack) {
              Log.err(error, 'image_error', stack);
              onImageError?.call();
            },
            child: body,
          ),
        ),
      ),
    );
  }
}

class EditImageHolder extends StatelessWidget {
  final String? path;
  final void Function(String)? onSelected;
  final void Function()? onPressed;
  final double size;

  const EditImageHolder({
    super.key,
    this.path,
    this.onSelected,
    this.onPressed,
    this.size = 256,
  }) : assert(onSelected != null || onPressed != null);

  @override
  Widget build(BuildContext context) {
    final ImageProvider image =
        path == null ? const AssetImage("assets/food_placeholder.png") as ImageProvider : FileImage(XFile(path!).file);

    return ImageHolder(
      key: const Key('image_holder.edit'),
      image: image,
      title: path == null ? S.imageHolderCreate : S.imageHolderUpdate,
      size: size,
      onPressed: onPressed ??
          () async {
            final file = await context.pushNamed(Routes.imageGallery);
            if (file != null && file is String) onSelected!(file);
          },
    );
  }
}
