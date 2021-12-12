import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/settings/order_product_axis_count_setting.dart';
import 'package:possystem/settings/setting.dart';

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

class OrderProductListState extends State<OrderProductList> {
  late List<Product> _products;

  late final int _crossAxisCount;

  @override
  Widget build(BuildContext context) {
    final body = _crossAxisCount == 0
        ? Wrap(children: [
            for (final product in _products)
              OutlinedButton(
                key: Key('order.product.${product.id}'),
                onPressed: () => _handleSelected(product),
                child: Text(product.name),
              )
          ])
        : GridView.count(
            crossAxisCount: _crossAxisCount,
            children: [
              for (final product in _products)
                _ImageCard(
                  product: product,
                  onTap: () => _handleSelected(product),
                ),
            ],
          );

    return Card(
      // Small top margin to avoid double size between catalogs
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(kSpacing1),
        child: body,
      ),
    );
  }

  @override
  void initState() {
    _products = widget.products;
    _crossAxisCount = SettingsProvider.instance
        .getSetting<OrderProductAxisCountSetting>()
        .value;
    super.initState();
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

class _ImageCard extends StatefulWidget {
  final Product product;

  final VoidCallback onTap;

  const _ImageCard({
    Key? key,
    required this.product,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<_ImageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late TickerFuture _ticker;

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
        widget.product.name,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18.0),
      ),
    );

    final card = Card(
      key: Key('order.product.${widget.product.id}'),
      child: Stack(
        alignment: Alignment.bottomCenter,
        fit: StackFit.expand,
        children: [
          Image(image: widget.product.image, fit: BoxFit.cover),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[Expanded(child: title)],
          ),
        ],
      ),
    );

    return GestureDetector(
      onTapDown: (_) {
        _ticker = _controller.forward();
      },
      onTapUp: (_) {
        _ticker.whenComplete(() => _controller.reverse());
      },
      onTapCancel: () {
        _ticker.whenComplete(() => _controller.reverse());
      },
      onTap: widget.onTap,
      child: Transform.scale(
        scale: 1 - _controller.value,
        child: card,
      ),
    );
  }

  @override
  void initState() {
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
}
