import 'package:flutter/material.dart';
import 'package:possystem/components/style/image_holder.dart';
import 'package:possystem/models/model.dart';

class SliverImageAppBar extends StatelessWidget {
  final ModelImage model;

  final List<Widget>? actions;

  const SliverImageAppBar({
    super.key,
    required this.model,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final background = ImageHolder(
      image: model.image,
      padding: const EdgeInsets.fromLTRB(0, 36, 0, 0),
      // required for the gradient
      title: '',
      onImageError: () => model.saveImage(null),
    );

    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      leading: const CloseButton(),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          model.name,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
        ),
        background: background,
      ),
      actions: actions,
    );
  }
}
