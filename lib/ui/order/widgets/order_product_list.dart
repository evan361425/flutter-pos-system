import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/cart.dart';

class OrderProductList extends StatefulWidget {
  final List<Product> products;

  final void Function(Product) handleSelected;

  const OrderProductList({
    Key? key,
    required this.products,
    required this.handleSelected,
  }) : super(key: key);

  @override
  OrderProductListState createState() => OrderProductListState();
}

class OrderProductListState extends State<OrderProductList>
    with SingleTickerProviderStateMixin {
  late List<Product> _products;

  late AnimationController _controller;

  late double _scale;

  String? _tappingProductId;

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;

    return Card(
      // Small top margin to avoid double size between catalogs
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(kSpacing1),
        child: GridView.count(
          crossAxisCount: 2,
          children: [
            for (final product in _products)
              GestureDetector(
                onTapDown: (_) {
                  _tappingProductId = product.id;
                  _controller.forward();
                },
                onTapUp: (_) => _controller.reverse(),
                onTapCancel: () => _controller.reverse(),
                onTap: () {
                  _controller.forward().then((_) => _controller.reverse());
                  _handleSelected(product);
                },
                child: Transform.scale(
                  scale: _tappingProductId == product.id ? _scale : 1,
                  child: _ImageCard(product),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    _products = widget.products;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0,
      upperBound: 0.05,
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void updateProducts(Catalog catalog) =>
      setState(() => _products = catalog.itemList);

  void _handleSelected(Product product) {
    Cart.instance
      ..toggleAll(false)
      ..add(product);
    // scroll to bottom
    widget.handleSelected(product);
  }
}

class _ImageCard extends StatelessWidget {
  final Product product;

  const _ImageCard(this.product, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).scaffoldBackgroundColor;

    final title = Container(
      padding: const EdgeInsets.fromLTRB(2, 8, 2, 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            color,
            color.withAlpha(200),
            color.withAlpha(0),
          ],
        ),
      ),
      child: Text(
        product.name,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18.0),
      ),
    );

    return Card(
      key: Key('order.product.${product.id}'),
      child: Stack(
        alignment: Alignment.bottomCenter,
        fit: StackFit.expand,
        children: [
          Image.asset(
            product.avator ?? 'assets/food_placeholder.png',
            fit: BoxFit.cover,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[Expanded(child: title)],
          ),
        ],
      ),
    );
  }
}
