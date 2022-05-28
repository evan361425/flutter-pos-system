import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';

class ItemMoreActionButton extends StatelessWidget {
  final Widget item;

  final VoidCallback onTap;

  const ItemMoreActionButton({
    Key? key,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing3),
      child: Row(children: [
        Expanded(child: item),
        IconButton(
          key: const Key('item_more_action'),
          onPressed: onTap,
          enableFeedback: true,
          icon: const Icon(KIcons.more),
        ),
      ]),
    );
  }
}
