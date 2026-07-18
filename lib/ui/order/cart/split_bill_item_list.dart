import 'package:flutter/material.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_product_object.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/translator.dart';

/// Tappable product lines for the split-bill dual lists.
class SplitBillItemList extends StatelessWidget {
  final String title;
  final List<OrderProductObject> items;
  final ValueChanged<OrderProductObject> onItemTap;
  final IconData emptyIcon;

  const SplitBillItemList({
    super.key,
    required this.title,
    required this.items,
    required this.onItemTap,
    this.emptyIcon = Icons.tap_and_play_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Padding(
          padding: const .fromLTRB(16, 12, 16, 4),
          child: Text(title, style: theme.textTheme.titleMedium),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Icon(
                    emptyIcon,
                    size: 48,
                    color: theme.colorScheme.outline,
                  ),
                )
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      key: Key('split_bill.item.${item.productId}.$index'),
                      title: Text(_label(item)),
                      subtitle: Text(
                        '${item.count} × ${item.singlePrice.toCurrency()}',
                      ),
                      trailing: Text(
                        item.totalPrice.toCurrency(),
                        style: theme.textTheme.titleSmall,
                      ),
                      onTap: () => onItemTap(item),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _label(OrderProductObject item) {
    final product = Menu.instance.getProduct(item.productId);
    return product?.name ??
        (item.productName.isEmpty
            ? S.orderCheckoutStashNoProducts
            : item.productName);
  }
}
