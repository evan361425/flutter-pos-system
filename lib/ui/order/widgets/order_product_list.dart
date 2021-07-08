import 'package:flutter/material.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/repository/cart_model.dart';

class OrderProductList extends StatefulWidget {
  const OrderProductList({
    Key? key,
    this.catalog,
    required this.handleSelected,
  }) : super(key: key);

  final CatalogModel? catalog;
  final void Function(ProductModel) handleSelected;

  @override
  OrderProductListState createState() => OrderProductListState();
}

class OrderProductListState extends State<OrderProductList> {
  late List<ProductModel> _products;

  void updateProducts(CatalogModel catalog) =>
      setState(() => _products = catalog.itemList);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Wrap(
            spacing: 4.0,
            children: [
              for (final product in _products)
                OutlinedButton(
                  onPressed: () => _handleSelected(product),
                  child: Text(product.name),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSelected(ProductModel product) {
    CartModel.instance
      ..toggleAll(false)
      ..add(product);
    widget.handleSelected(product);
  }

  @override
  void initState() {
    _products = widget.catalog?.itemList ?? const [];
    super.initState();
  }
}
