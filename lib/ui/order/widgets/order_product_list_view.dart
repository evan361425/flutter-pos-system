import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/image_holder.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/order_page.dart';

class OrderProductListView extends StatelessWidget {
  final List<Product> products;

  final ProductListView view;

  const OrderProductListView({
    super.key,
    required this.products,
    required this.view,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: kTopSpacing, bottom: kFABSpacing),
      child: _buildView(context),
    );
  }

  Widget _buildView(BuildContext context) {
    if (view == ProductListView.list) {
      return _buildListView(context);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // each width should between 200 and 320
        return _buildGridView(Breakpoint.find(box: constraints).lookup(
          compact: 2,
          medium: 3,
          expanded: 4,
          large: 5,
        ));
      },
    );
  }

  Widget _buildGridView(int crossAxisCount) {
    return Center(
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12.0,
        crossAxisSpacing: 8.0,
        children: [
          for (final product in products)
            ImageHolder(
              key: Key('order.product.${product.id}'),
              image: product.image,
              title: product.name,
              onPressed: () => _onSelected(product),
            )
        ],
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    return ListView(children: [
      for (final product in products)
        ListTile(
          key: Key('order.product.${product.id}'),
          title: Text(product.name),
          subtitle: MetaBlock.withString(
            context,
            product.itemList.map((e) => e.name).toList(),
            emptyText: S.orderProductListNoIngredient,
          ),
          onTap: () => _onSelected(product),
        ),
    ]);
  }

  void _onSelected(Product product) {
    Cart.instance.add(product);
  }
}
