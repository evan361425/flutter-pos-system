import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/cashier/order_cashier_product_list.dart';

class AnalysisOrderModal extends StatelessWidget {
  final OrderObject order;

  const AnalysisOrderModal(this.order, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PopButton(),
        actions: [
          IconButton(
            key: const Key('analysis.more'),
            onPressed: () => _showActions(context),
            enableFeedback: true,
            icon: const Icon(KIcons.more),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: HintText(_parseCreatedAt(order.createdAt)),
        ),
        Expanded(
          child: OrderCashierProductList(
            attributes: order.attributes.toList(),
            products: order.products
                .map((product) => OrderProductTileData(
                    product: Menu.instance.getProduct(product.productId),
                    productName: product.productName,
                    ingredientNames:
                        product.ingredients.map((e) => e.quantityName == null
                            ? S.orderProductIngredientDefaultName(e.name)
                            : S.orderProductIngredientName(
                                e.name,
                                e.quantityName!,
                              )),
                    totalCount: product.count,
                    totalCost: product.totalCost,
                    totalPrice: product.totalPrice))
                .toList(),
            productsPrice: order.productsPrice,
            totalPrice: order.totalPrice,
            productCost: order.cost,
            income: order.income,
            paid: order.paid,
          ),
        ),
      ]),
    );
  }

  Future<void> _showActions(BuildContext context) async {
    final form = GlobalKey<_WarningContextState>();
    await BottomSheetActions.withDelete<_Action>(
      context,
      deleteCallback: () => showSnackbarWhenFailed(
        Seller.instance.delete(order, form.currentState?.recoverOther ?? false),
        context,
        'analysis_delete_error',
      ),
      deleteValue: _Action.delete,
      popAfterDeleted: true,
      warningContent: _WarningContext(order, key: form),
    );
  }
}

class _WarningContext extends StatefulWidget {
  final OrderObject order;

  const _WarningContext(this.order, {Key? key}) : super(key: key);

  @override
  State<_WarningContext> createState() => _WarningContextState();
}

class _WarningContextState extends State<_WarningContext> {
  bool recoverOther = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('確定要刪除 ${_parseCreatedAt(widget.order.createdAt)} 的訂單嗎？'),
        const Text('\n此動作無法復原'),
        const Divider(height: 32),
        CheckboxListTile(
          key: const Key('analysis.tile_del_with_other'),
          autofocus: true,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: recoverOther,
          selected: recoverOther,
          onChanged: _onChanged,
          title: const Text('復原對應的庫存和收銀機資料'),
        ),
        if (recoverOther) ..._iterStockHint(context),
        if (recoverOther) ..._iterCashierHint(context),
      ]),
    );
  }

  Iterable<Widget> _iterStockHint(BuildContext context) sync* {
    final amounts = <String, num>{};
    widget.order.fillIngredient(amounts, add: true);

    for (final entry in amounts.entries) {
      final ing = Stock.instance.getItem(entry.key);
      if (ing != null && entry.value != 0) {
        final operator = entry.value > 0 ? '增加' : '減少';
        final v = entry.value > 0 ? entry.value : -entry.value;
        yield Text('${(ing.name)} 將$operator $v 單位');
      }
    }
  }

  Iterable<Widget> _iterCashierHint(BuildContext context) sync* {
    final amounts = <int, int>{};
    final status = Cashier.instance.smallChange(
      amounts,
      widget.order.totalPrice,
      add: false,
    );

    for (final entry in amounts.entries) {
      final e = Cashier.instance.at(entry.key);
      yield Text(
          '${e.unit} 元將減少 ${-entry.value} 個至 ${e.count + entry.value} 個');
    }

    String? errorText;
    switch (status) {
      case CashierUpdateStatus.notEnough:
        errorText = '收銀機將不夠錢換，不管了。';
        break;
      case CashierUpdateStatus.usingSmall:
        errorText = '收銀機要用小錢換才能滿足。';
        break;
      default:
        break;
    }
    if (errorText != null) {
      yield Text(
        errorText,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }
  }

  void _onChanged(value) {
    setState(() {
      recoverOther = value ?? false;
    });
  }
}

enum _Action {
  delete,
}

String _parseCreatedAt(DateTime t) {
  return DateFormat.MMMEd(S.localeName).format(t) +
      MetaBlock.string +
      DateFormat.jms(S.localeName).format(t);
}
