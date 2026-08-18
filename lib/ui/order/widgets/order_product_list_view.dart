import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/image_holder.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/helpers/util.dart';
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
      padding: const .only(top: kTopSpacing, bottom: kFABSpacing),
      child: _buildView(context),
    );
  }

  Widget _buildView(BuildContext context) {
    if (view == .list) {
      return _buildListView(context);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // each width should between 200 and 320
        return _buildGridView(
          context,
          Breakpoint.find(
            box: constraints,
          ).lookup(compact: 2, medium: 3, expanded: 4, large: 5),
        );
      },
    );
  }

  Widget _buildGridView(BuildContext context, int crossAxisCount) {
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
              onPressed: () => _onSelected(context, product),
            ),
        ],
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    return ListView(
      children: [
        for (final product in products)
          ListTile(
            key: Key('order.product.${product.id}'),
            title: Text(product.name),
            subtitle: MetaBlock.withString(
              context,
              product.itemList.map((e) => e.name).toList(),
              emptyText: S.orderProductListNoIngredient,
            ),
            onTap: () => _onSelected(context, product),
          ),
      ],
    );
  }

  void _onSelected(BuildContext context, Product product) async {
    final count = await showDialog<num>(
      context: context,
      builder: (context) => _ProductQuickAddDialog(product),
    );
    if (count != null) {
      Cart.instance.add(product, count: count);
    }
  }
}

class _ProductQuickAddDialog extends StatefulWidget {
  final Product product;

  const _ProductQuickAddDialog(this.product);

  @override
  State<_ProductQuickAddDialog> createState() => _ProductQuickAddDialogState();
}

class _ProductQuickAddDialogState extends State<_ProductQuickAddDialog> {
  late num count;
  bool addToCart = false;

  num get step => widget.product.isWeightBased ? 0.1 : 1;

  @override
  void initState() {
    super.initState();
    count = widget.product.isWeightBased ? 0.5 : 1;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product.name),
      content: Column(
        mainAxisSize: .min,
        children: [
          ListTile(
            contentPadding: .zero,
            title: Text(S.orderQuickAddUnitPrice),
            trailing: Text(widget.product.price.toCurrency()),
          ),
          Row(
            mainAxisAlignment: .center,
            children: [
              Text(
                count.toShortString(),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                key: const Key('order.quick_add.increase'),
                tooltip: S.orderCartProductIncrease,
                onPressed: () => setState(() {
                  count = widget.product.isWeightBased
                      ? ((count + step) * 1000).round() / 1000
                      : count + 1;
                }),
                icon: const Icon(Icons.add_circle_outline),
              ),
              IconButton(
                key: const Key('order.quick_add.decrease'),
                tooltip: S.orderCartProductDecrease,
                onPressed: count <= step
                    ? null
                    : () => setState(() {
                        count = widget.product.isWeightBased
                            ? ((count - step) * 1000).round() / 1000
                            : count - 1;
                      }),
                icon: const Icon(Icons.remove_circle_outline),
              ),
            ],
          ),
          CheckboxListTile(
            key: const Key('order.quick_add.confirm_checkbox'),
            contentPadding: .zero,
            value: addToCart,
            onChanged: (value) => setState(() => addToCart = value ?? false),
            title: Text(S.orderQuickAddConfirm),
            controlAffinity: .leading,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          key: const Key('order.quick_add.add'),
          onPressed: addToCart ? () => Navigator.pop(context, count) : null,
          child: Text(S.orderQuickAddAction),
        ),
      ],
    );
  }
}
