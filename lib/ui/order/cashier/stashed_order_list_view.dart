import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/item_loader.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/more_button.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/cashier/order_cashier_calculator.dart';

class StashedOrderListView extends StatelessWidget {
  final void Function(CheckoutStatus status) handleCheckout;

  const StashedOrderListView({
    Key? key,
    required this.handleCheckout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ItemLoader<OrderObject, OrderMetrics>(
      builder: _buildTile,
      loader: (int offset) {
        return Seller.instance.getStashedOrders(offset: offset);
      },
      prototypeItem: _buildTile(
        context,
        OrderObject(createdAt: DateTime.now()),
      ),
      metricsLoader: Seller.instance.getStashedMetrics,
      metricsBuilder: (metrics) {
        return Center(child: Text(S.orderListMetaCount(metrics.count)));
      },
    );
  }

  Widget _buildTile(BuildContext context, OrderObject order) {
    final n = DateTime.now();
    final title = order.createdAt.isBefore(DateTime(n.year, n.month, n.day))
        ? DateFormat.MMMEd(S.localeName).format(order.createdAt) +
            MetaBlock.string +
            DateFormat.Hms(S.localeName).format(order.createdAt)
        : DateFormat.Hms(S.localeName).format(order.createdAt);

    final products = order.products
        .map((e) {
          final p = Menu.instance.getProduct(e.productId);
          if (p == null) return null;
          return e.count == 1 ? p.name : '${p.name} * ${e.count}';
        })
        .where((e) => e != null)
        .cast<String>();

    return ListTile(
      title: Text(title),
      subtitle: MetaBlock.withString(context, products, emptyText: '沒有任何產品'),
      trailing: MoreButton(onPressed: () => _showActions(context, order)),
      onTap: () => _act(_Action.checkout, context, order),
      onLongPress: () => _showActions(context, order),
    );
  }

  void _showActions(BuildContext context, OrderObject order) async {
    final action = await BottomSheetActions.withDelete(
      context,
      actions: const [
        BottomSheetAction(
          title: Text('結帳'),
          leading: Icon(Icons.price_check_sharp),
          returnValue: _Action.checkout,
        ),
        BottomSheetAction(
          title: Text('復原'),
          leading: Icon(Icons.file_upload),
          returnValue: _Action.restore,
        ),
      ],
      deleteValue: _Action.delete,
      warningContent: Text(S.dialogDeletionContent('訂單', '')),
      deleteCallback: () => _act(_Action.delete, context, order),
    );

    if (action != null) {
      // I will make sure mounted in _act
      // ignore: use_build_context_synchronously
      _act(action, context, order);
    }
  }

  Future<void> _act(
    _Action act,
    BuildContext context,
    OrderObject order,
  ) async {
    switch (act) {
      case _Action.restore:
        bool ok = true;
        if (!Cart.instance.isEmpty) {
          ok = await ConfirmDialog.show(context, title: '要覆蓋購物車資料嗎？');
        }

        if (ok) {
          Cart.instance.restore(order);
          await Seller.instance.deleteStashedOrder(order.id ?? 0);
        }
        break;
      case _Action.checkout:
        if (context.mounted) {
          final cart = Cart()..restore(order);
          final price = ValueNotifier<num>(cart.price);
          final paid = ValueNotifier<num>(price.value);
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => SimpleDialog(children: [
              OrderCashierCalculator(
                onSubmit: () => Navigator.of(context).pop(true),
                price: price,
                paid: paid,
              ),
            ]),
          );

          if (confirmed == true) {
            handleCheckout(await cart.checkout(price.value, paid.value));
          }
        }
        break;
      case _Action.delete:
        await Seller.instance.deleteStashedOrder(order.id ?? 0);
    }
  }
}

enum _Action {
  delete,
  restore,
  checkout,
}
