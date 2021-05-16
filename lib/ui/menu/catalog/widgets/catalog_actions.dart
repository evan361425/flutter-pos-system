import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/ui/menu/catalog/widgets/product_orderable_list.dart';
import 'package:possystem/ui/menu/menu_routes.dart';

class CatalogActions extends StatelessWidget {
  const CatalogActions({Key key, @required this.catalog}) : super(key: key);

  final CatalogModel catalog;

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pushReplacementNamed(
            MenuRoutes.catalogModal,
            arguments: catalog,
          ),
          child: Text('變更名稱'),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ProductOrderableList(items: catalog.productList),
            ),
          ),
          child: Text('排序產品'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context, 'cancel'),
        child: Text('取消'),
      ),
    );
  }
}
