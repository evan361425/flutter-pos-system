import 'package:flutter/material.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:provider/provider.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var catalog = Provider.of<CatalogModel>(context);
    return Column(
      children: [
        Text(catalog.createdAt.toString()),
      ],
    );
  }
}
