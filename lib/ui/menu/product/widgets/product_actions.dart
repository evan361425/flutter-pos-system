import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/ui/menu/menu_routes.dart';

class ProductActions extends StatelessWidget {
  const ProductActions({Key key, @required this.product}) : super(key: key);

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pushReplacementNamed(
            MenuRoutes.productModal,
            arguments: product,
          ),
          child: Text('變更產品'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context, 'cancel'),
        child: Text('取消'),
      ),
    );
  }
}
