import 'package:flutter/material.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/routes.dart';

import 'widgets/quantity_body.dart';

class QuantityScreen extends StatelessWidget {
  const QuantityScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('份量'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(
          Routes.stockQuantityModal,
        ),
        tooltip: '新增份量',
        child: Icon(KIcons.add),
      ),
      body: QuantityBoby(),
    );
  }
}
