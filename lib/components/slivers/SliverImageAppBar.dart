import 'package:flutter/material.dart';
import 'package:possystem/components/style/pop_button.dart';

class SliverImageAppBar extends StatelessWidget {
  final String title;

  final ImageProvider<Object> image;

  const SliverImageAppBar({
    Key? key,
    required this.title,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      leading: const PopButton(),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(title),
        titlePadding: const EdgeInsets.fromLTRB(48, 0, 48, 6),
        background: Image(
          image: image,
          fit: BoxFit.cover,
          color: Theme.of(context).backgroundColor.withOpacity(0.7),
          colorBlendMode: BlendMode.srcATop,
        ),
      ),
      actions: const <Widget>[PopButton(toHome: true)],
    );
  }
}
