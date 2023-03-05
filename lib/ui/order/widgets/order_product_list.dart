import 'package:flutter/material.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/settings/order_product_axis_count_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:spotlight_ant/spotlight_ant.dart';

class OrderProductList extends StatelessWidget {
  final List<Product> products;

  const OrderProductList({
    Key? key,
    required this.products,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final count = SettingsProvider.of<OrderProductAxisCountSetting>().value;
    int index = 0;

    return Card(
      // Small top margin to avoid double size between catalogs
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(kSpacing1),
        child: count == 0
            ? Wrap(children: [
                for (final product in products)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: OutlinedButton(
                      key: Key('order.product.${product.id}'),
                      onPressed: () => _onSelected(product),
                      child: Text(product.name),
                    ),
                  ),
              ])
            : GridView.count(
                crossAxisCount: count,
                children: [
                  for (final product in products)
                    Tutorial(
                      id: 'order.menu_product',
                      title: '開始點餐！',
                      message: '透過圖片點餐更方便！\n'
                          '你也可以到「設定」頁面，\n'
                          '設定「每行顯示幾個產品」或僅使用文字點餐',
                      spotlightBuilder:
                          const SpotlightRectBuilder(borderRadius: 16),
                      disable: index++ != 0,
                      child: _ImageCard(
                        product: product,
                        onTap: () => _onSelected(product),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  void _onSelected(Product product) {
    Cart.instance
      ..toggleAll(false)
      ..add(product);
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
      child: Text(widget.product.name, textAlign: TextAlign.center),
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
