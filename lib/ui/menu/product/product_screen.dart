import 'package:flutter/material.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/models/product_model.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogModel>();
    final ProductModel product = ModalRoute.of(context).settings.arguments ??
        ProductModel.empty(catalog.name);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(Local.of(context).t('menu.product.title')),
      ),
      body: Column(
        children: [
          Text(catalog.name),
          Text(product.name),
        ],
      ),
    );
  }
}
