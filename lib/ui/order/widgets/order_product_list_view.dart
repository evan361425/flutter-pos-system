import 'package:flutter/material.dart';
import 'package:possystem/components/style/image_holder.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/settings/order_product_axis_count_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:spotlight_ant/spotlight_ant.dart';

class OrderProductListView extends StatelessWidget {
  final List<Product> products;

  const OrderProductListView({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final count = SettingsProvider.of<OrderProductAxisCountSetting>().value;
    int index = 0;

    return Padding(
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
              mainAxisSpacing: 12.0,
              crossAxisSpacing: 8.0,
              children: [
                for (final product in products)
                  Tutorial(
                    id: 'order.menu_product',
                    title: '開始點餐！',
                    message: '透過圖片點餐更方便！\n'
                        '你也可以到「設定」頁面，\n'
                        '設定「每行顯示幾個產品」或僅使用文字點餐',
                    spotlightBuilder: const SpotlightRectBuilder(borderRadius: 16),
                    disable: index++ != 0,
                    child: ImageHolder(
                      key: Key('order.product.${product.id}'),
                      image: product.image,
                      title: product.name,
                      onPressed: () => _onSelected(product),
                    ),
                  )
              ],
            ),
    );
  }

  void _onSelected(Product product) {
    Cart.instance.add(product);
  }
}
