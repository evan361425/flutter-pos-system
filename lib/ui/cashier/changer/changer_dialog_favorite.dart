import 'package:flutter/material.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/models/repository/cashier.dart';

class ChangerDialogFavorite extends StatelessWidget {
  final void Function() handleAdd;

  const ChangerDialogFavorite({
    Key? key,
    required this.handleAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Cashier.instance.favorites.isEmpty) {
      return EmptyBody(
        body: OutlinedButton(onPressed: handleAdd, child: Text('立即設定')),
      );
    }
    return Container(
      child: Text('hi'),
    );
  }
}
