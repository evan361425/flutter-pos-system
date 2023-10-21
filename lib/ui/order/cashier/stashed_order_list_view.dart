import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/item_loader.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/more_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/stashed_orders.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/cashier/order_cashier_calculator.dart';

class StashedOrderListView extends StatelessWidget {
  const StashedOrderListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ItemLoader<OrderObject, StashedOrderMetrics>(
      builder: _buildTile,
      notifier: StashedOrders.instance,
      loader: (int offset) {
        return StashedOrders.instance.getItems(offset: offset);
      },
      prototypeItem: _buildTile(
        context,
        OrderObject(createdAt: DateTime.now()),
      ),
      metricsLoader: StashedOrders.instance.getMetrics,
      metricsBuilder: (metrics) {
        return Center(child: Text(S.orderListMetaCount(metrics.count)));
      },
      emptyChild: const Center(child: HintText('目前無任何暫存餐點。')),
    );
  }

  Widget _buildTile(BuildContext context, OrderObject order) {
    final n = DateTime.now();
    final title = order.createdAt.isBefore(DateTime(n.year, n.month, n.day))
        ? DateFormat.MMMd(S.localeName).format(order.createdAt) +
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
      key: Key('stashed_order.${order.id}'),
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
          await StashedOrders.instance.delete(order.id ?? 0);

          if (context.mounted && context.canPop()) {
            context.pop(CheckoutStatus.restore);
          }
        }
        break;
      case _Action.checkout:
        // ignore: use_build_context_synchronously
        await _checkout(context, order);
        break;
      case _Action.delete:
        await StashedOrders.instance.delete(order.id ?? 0);
        if (context.mounted) {
          showSnackBar(context, S.orderCashierPaidFailed);
        }
    }
  }

  Future<void> _checkout(
    BuildContext context,
    OrderObject order,
  ) async {
    final cart = Cart(name: 'stashed')..restore(order);
    final price = ValueNotifier<num>(cart.price);
    final paid = ValueNotifier<num>(price.value);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => SimpleDialog(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 4.0,
          vertical: 24.0,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 8.0,
        ),
        semanticLabel: '結帳計算機',
        children: [
          SizedBox(
            height: 360.0,
            child: OrderCashierCalculator(
              onSubmit: () => Navigator.of(context).pop(true),
              price: price,
              paid: paid,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final status = await cart.checkout(price.value, paid.value);
      if (status == CheckoutStatus.paidNotEnough) {
        if (context.mounted) {
          showSnackBar(context, S.orderCashierPaidFailed);
        }
        return;
      }

      await StashedOrders.instance.delete(order.id ?? 0);

      if (context.mounted && context.canPop()) {
        context.pop(status);
      }
    }
  }
}

enum _Action {
  delete,
  restore,
  checkout,
}
