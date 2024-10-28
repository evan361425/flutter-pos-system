import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/item_loader.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/buttons.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/stashed_orders.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/checkout/checkout_cashier_calculator.dart';
import 'package:possystem/ui/order/order_page.dart';

class StashedOrderListView extends StatelessWidget {
  const StashedOrderListView({super.key});

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
        return Center(child: Text(S.totalCount(metrics.count)));
      },
      emptyChild: Center(child: HintText(S.orderCheckoutStashEmpty)),
      padding: const EdgeInsets.only(bottom: 428),
    );
  }

  Widget _buildTile(BuildContext context, OrderObject order) {
    final n = DateTime.now();
    final title = order.createdAt.isBefore(DateTime(n.year, n.month, n.day))
        ? DateFormat.MMMd(S.localeName).format(order.createdAt) +
            MetaBlock.string +
            DateFormat.Hm(S.localeName).format(order.createdAt)
        : DateFormat.Hms(S.localeName).format(order.createdAt);

    final products = order.products
        .map((e) {
          final p = Menu.instance.getProduct(e.productId);
          if (p == null) return null;
          return e.count == 1 ? p.name : '${p.name} * ${e.count}';
        })
        .where((e) => e != null)
        .cast<String>();

    return Dismissible(
      key: ObjectKey(order),
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        color: const Color(0xFF198753),
        child: const Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: Icon(Icons.file_upload, color: Color(0xFF051B11)),
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _act(_Action.restore, context, order),
      child: ListTile(
        key: Key('stashed_order.${order.id}'),
        title: Text(title),
        subtitle: MetaBlock.withString(context, products, emptyText: S.orderCheckoutStashNoProducts),
        trailing: MoreButton(onPressed: (context) => _showActions(context, order)),
        onTap: () => _act(_Action.checkout, context, order),
        onLongPress: () => _showActions(context, order),
      ),
    );
  }

  void _showActions(BuildContext context, OrderObject order) async {
    final action = await BottomSheetActions.withDelete(
      context,
      actions: [
        BottomSheetAction(
          title: Text(S.orderCheckoutStashActionCheckout),
          leading: const Icon(Icons.price_check_outlined),
          returnValue: _Action.checkout,
        ),
        BottomSheetAction(
          title: Text(S.orderCheckoutStashActionRestore),
          leading: const Icon(Icons.file_upload_outlined),
          returnValue: _Action.restore,
        ),
      ],
      deleteValue: _Action.delete,
      warningContent: Text(S.dialogDeletionContent(S.orderCheckoutStashDialogDeleteName, '')),
      deleteCallback: () => _act(_Action.delete, context, order),
    );

    if (action != null) {
      // I will make sure mounted in _act
      // ignore: use_build_context_synchronously
      _act(action, context, order);
    }
  }

  Future<bool?> _act(
    _Action act,
    BuildContext context,
    OrderObject order,
  ) async {
    switch (act) {
      case _Action.restore:
        bool ok = true;
        if (!Cart.instance.isEmpty) {
          ok = await ConfirmDialog.show(
            context,
            title: S.orderCheckoutStashDialogRestoreTitle,
            content: S.orderCheckoutStashDialogRestoreContent,
          );
        }

        if (ok) {
          Cart.instance.restore(order);
          await StashedOrders.instance.delete(order.id ?? 0);

          if (context.mounted && context.canPop()) {
            context.pop(CheckoutStatus.restore);
          }
        }
        return ok;
      case _Action.checkout:
        // ignore: use_build_context_synchronously
        await _checkout(context, order);
        break;
      case _Action.delete:
        await StashedOrders.instance.delete(order.id ?? 0);
        if (context.mounted) {
          showSnackBar(S.actSuccess, context: context);
        }
    }
    return true;
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
        semanticLabel: S.orderCheckoutStashDialogCalculator,
        children: [
          SizedBox(
            height: 360.0,
            child: CheckoutCashierCalculator(
              onSubmit: () => Navigator.of(context).pop(true),
              price: price,
              paid: paid,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final future = cart.checkout(paid: paid.value, context: context);
      final status = await showSnackbarWhenFutureError(future, 'stashed_order_checkout', context: context);

      if (status == CheckoutStatus.paidNotEnough || status == null) {
        if (context.mounted && status != null) {
          showSnackBar(S.orderCheckoutSnackbarPaidFailed, context: context);
        }
        return;
      }

      if (context.mounted) {
        await showSnackbarWhenFutureError(
          StashedOrders.instance.delete(order.id ?? 0),
          'stashed_order_finished',
          context: context,
        );

        if (context.mounted) {
          handleCheckoutStatus(context, status);
        }
      }
    }
  }
}

enum _Action {
  delete,
  restore,
  checkout,
}
