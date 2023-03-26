import 'package:flutter/material.dart';
import 'package:possystem/components/style/image_holder.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/models/model.dart';

class SliverImageAppBar extends StatelessWidget {
  final ModelImage model;

  const SliverImageAppBar({
    Key? key,
    required this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      leading: const PopButton(),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          model.name,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
        ),
        titlePadding: const EdgeInsets.fromLTRB(48, 0, 48, 6),
        background: ImageHolder(
          image: model.image,
          padding: const EdgeInsets.fromLTRB(0, 36, 0, 0),
          title: '',
          onImageError: () => model.saveImage(null),
        ),
      ),
      actions: const <Widget>[PopButton(toHome: true)],
    );
  }
}
