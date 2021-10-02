import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/model.dart';

class ItemMoreActionButton extends StatelessWidget {
  final Model item;

  final Widget? metadata;

  final VoidCallback onTap;

  const ItemMoreActionButton({
    Key? key,
    required this.item,
    required this.onTap,
    this.metadata,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headline4;

    return Container(
      padding: const EdgeInsets.all(kSpacing3),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(item.name, style: titleStyle),
              if (metadata != null) const SizedBox(height: 4.0),
              if (metadata != null) metadata!,
            ],
          ),
        ),
        IconButton(
          onPressed: onTap,
          icon: Icon(KIcons.more),
        ),
      ]),
    );
  }
}
