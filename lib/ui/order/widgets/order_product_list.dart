import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/cart.dart';

class OrderProductList extends StatefulWidget {
  const OrderProductList({
    Key? key,
    required this.products,
    required this.handleSelected,
  }) : super(key: key);

  final List<Product> products;
  final void Function(Product) handleSelected;

  @override
  OrderProductListState createState() => OrderProductListState();
}

class OrderProductListState extends State<OrderProductList> {
  late List<Product> _products;

  void updateProducts(Catalog catalog) =>
      setState(() => _products = catalog.itemList);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 4.0),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(kSpacing1),
          child: Wrap(
            spacing: kSpacing1,
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

  void _handleSelected(Product product) {
    Cart.instance
      ..toggleAll(false)
      ..add(product);
    // scroll to bottom
    widget.handleSelected(product);
  }

  @override
  void initState() {
    _products = widget.products;
    super.initState();
  }
}
