import 'package:flutter/material.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/model.dart';

class ItemEditableInfo extends StatelessWidget {
  final Model item;

  final Widget? metadata;

  final VoidCallback onEdit;

  const ItemEditableInfo({
    Key? key,
    required this.item,
    required this.onEdit,
    this.metadata,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headline4;

    return Row(children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(item.name, style: titleStyle),
            if (metadata != null) metadata!,
          ],
        ),
      ),
      IconButton(
        onPressed: onEdit,
        icon: Icon(KIcons.edit),
      ),
    ]);
  }
}
