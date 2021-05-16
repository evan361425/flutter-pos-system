import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/models/repository/menu_model.dart';

import 'catalog_orderable_list.dart';

class MenuActions extends StatelessWidget {
  const MenuActions({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) {
                final items = MenuModel.instance.catalogList;
                return CatalogOrderableList(items: items);
              },
            ),
          ),
          child: Text('排序產品種類'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context, 'cancel'),
        child: Text('取消'),
      ),
    );
  }
}
