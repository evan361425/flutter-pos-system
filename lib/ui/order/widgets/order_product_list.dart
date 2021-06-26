import 'package:flutter/material.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/repository/cart_model.dart';
import 'package:possystem/ui/order/cart/cart_product_list.dart';

class OrderProductList extends StatefulWidget {
  const OrderProductList({
    Key? key,
    required this.catalog,
    required this.productsKey,
  }) : super(key: key);

  final CatalogModel? catalog;
  final GlobalKey<CartProductListState> productsKey;

  @override
  OrderProductListState createState() => OrderProductListState();
}

class OrderProductListState extends State<OrderProductList> {
  CatalogModel? _catalog;

  set catalog(CatalogModel catalog) => setState(() => _catalog = catalog);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Wrap(
            spacing: 4.0,
            children: [
              for (final product in _catalog?.itemList ?? [])
                OutlinedButton(
                  onPressed: () => onSelected(product),
                  child: Text(product.name),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void onSelected(ProductModel product) {
    CartModel.instance.toggleAll(false);
    CartModel.instance.add(product).toggleSelected(true);
    widget.productsKey.currentState!.scrollToBottom();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _catalog = widget.catalog;
  }
}
