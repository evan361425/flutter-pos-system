import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/slider_text_dialog.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/percentile_bar.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';

class StockIngredientListTile extends StatelessWidget {
  final Ingredient item;

  const StockIngredientListTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key('stock.${item.id}'),
      title: Text(item.name),
      subtitle: PercentileBar(item.currentAmount, item.maxAmount),
      onLongPress: () => showActions(context),
      onTap: () => editAmount(context),
      trailing: IconButton(
        key: Key('stock.${item.id}.edit'),
        tooltip: S.stockIngredientTitleUpdate,
        onPressed: () => editIngredient(context),
        icon: const Icon(KIcons.edit),
      ),
    );
  }

  void editIngredient(BuildContext context) {
    context.pushNamed(
      Routes.stockIngrUpdate,
      pathParameters: {'id': item.id},
    );
  }

  void showActions(BuildContext context) async {
    final count = Menu.instance.getIngredients(item.id).length;
    final more = S.stockIngredientDialogDeletionContent(count);

    final result = await BottomSheetActions.withDelete<_Actions>(
      context,
      deleteValue: _Actions.delete,
      warningContent: Text(S.dialogDeletionContent(item.name, '$more\n\n')),
      deleteCallback: delete,
      actions: [
        BottomSheetAction(
          title: Text(S.stockIngredientTitleUpdateAmount),
          leading: const Icon(Icons.edit_square),
          returnValue: _Actions.edit,
        ),
        BottomSheetAction(
          key: const Key('btn.edit'),
          title: Text(S.stockIngredientTitleUpdate),
          leading: const Icon(KIcons.edit),
          route: Routes.stockIngrUpdate,
          routePathParameters: {'id': item.id},
        ),
      ],
    );

    if (result == _Actions.edit && context.mounted) {
      editAmount(context);
    }
  }

  Future<void> delete() async {
    await item.remove();
    return Menu.instance.removeIngredients(item.id);
  }

  Future<void> editAmount(BuildContext context) async {
    final result = await showAdaptiveDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final currentValue = ValueNotifier<String?>(null);
        return SliderTextDialog(
          title: Text(item.name),
          value: item.currentAmount.toDouble(),
          max: item.maxAmount,
          builder: (child, onSubmit) => _RestockDialog(
            ingredient: item,
            quantityTab: child,
            onSubmit: onSubmit,
            currentValue: currentValue,
          ),
          currentValue: currentValue,
          decoration: InputDecoration(
            label: Text(S.stockIngredientRestockDialogQuantityLabel),
            helperText: S.stockIngredientRestockDialogQuantityHelper,
            helperMaxLines: 3,
          ),
          validator: Validator.positiveNumber(S.stockIngredientRestockDialogQuantityLabel),
        );
      },
    );

    if (result != null) {
      await item.setAmount(num.tryParse(result) ?? 0);
    }
  }
}

class _RestockDialog extends StatefulWidget {
  final Ingredient ingredient;

  final Widget quantityTab;

  final void Function(String?) onSubmit;

  final ValueNotifier<String?> currentValue;

  const _RestockDialog({
    required this.ingredient,
    required this.onSubmit,
    required this.quantityTab,
    required this.currentValue,
  });

  @override
  State<_RestockDialog> createState() => _RestockDialogState();
}

class _RestockDialogState extends State<_RestockDialog> {
  late ReplenishBy replenishBy;
  late final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildChild(),
        const SizedBox(height: 8.0),
        ElevatedButton.icon(
          key: const Key('stock.repl.switch'),
          onPressed: switchMethod,
          // switch method, so the label is opposite
          label: Text(replenishBy == ReplenishBy.quantity
              ? S.stockIngredientRestockDialogPriceBtn
              : S.stockIngredientRestockDialogQuantityBtn),
          icon: const Icon(Icons.currency_exchange_outlined),
        ),
      ],
    );
  }

  Widget buildChild() {
    if (replenishBy == ReplenishBy.quantity) {
      return widget.quantityTab;
    }

    if (widget.ingredient.restockPrice == null) {
      return Center(
        child: EmptyBody(
          content: S.stockIngredientRestockDialogPriceEmptyBody,
          routeName: Routes.stockIngrRestock,
          pathParameters: {'id': widget.ingredient.id},
        ),
      );
    }

    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyLarge!,
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (popped, _) async {
          if (popped && widget.currentValue.value != null) {
            final price = num.tryParse(controller.text);
            if (price != null) {
              await widget.ingredient.update(IngredientObject(
                restockLastPrice: price,
              ));
            }
          }
        },
        child: buildPriceTab(),
      ),
    );
  }

  Widget buildPriceTab() {
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(S.stockIngredientRestockDialogTitle(
          widget.ingredient.restockQuantity.toShortString(),
          widget.ingredient.restockPrice!.toShortString(),
        )),
        subtitle: Text(S.stockIngredientRestockDialogSubtitle),
        trailing: IconButton(
          icon: const Icon(KIcons.edit),
          onPressed: () => context.pushNamed(Routes.stockIngrRestock, pathParameters: {
            'id': widget.ingredient.id,
          }),
        ),
      ),
      TextFormField(
        key: const Key('stock.repl.price.text'),
        controller: controller,
        onSaved: widget.onSubmit,
        onFieldSubmitted: widget.onSubmit,
        autofocus: true,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.end,
        decoration: InputDecoration(
          label: Text(S.stockIngredientRestockDialogPriceLabel),
          prefix: const Text(r'$'),
        ),
        validator: Validator.positiveNumber(S.stockIngredientRestockDialogPriceLabel),
        textInputAction: TextInputAction.done,
      ),
      const SizedBox(height: 8.0),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('÷', style: TextStyle(color: Colors.grey, fontSize: 14, inherit: true)),
        // this money is independent to currency, so we don't need use
        // currency to format it.
        Text('\$${widget.ingredient.restockPrice!.toShortString()}'),
      ]),
      const SizedBox(height: 8.0),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('*', style: TextStyle(color: Colors.grey, fontSize: 14, inherit: true)),
        Text(widget.ingredient.restockQuantity.toShortString()),
      ]),
      const SizedBox(height: 8.0),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          '+ (${S.stockIngredientRestockDialogPriceOldAmount})',
          style: const TextStyle(color: Colors.grey, fontSize: 14.0, inherit: true),
        ),
        Text(widget.ingredient.currentAmount.toShortString()),
      ]),
      const Divider(),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('=', style: TextStyle(color: Colors.grey, fontSize: 14.0, inherit: true)),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final price = num.tryParse(controller.text);
            if (price == null) {
              widget.currentValue.value = null;
              return Text(widget.ingredient.currentAmount.toShortString());
            }

            final quantity = price / widget.ingredient.restockPrice! * widget.ingredient.restockQuantity;
            final value = (quantity + widget.ingredient.currentAmount).toShortString();
            widget.currentValue.value = value;
            return Text(value);
          },
        ),
      ]),
    ]);
  }

  @override
  void initState() {
    final index = Cache.instance.get<int>('stock.replenishBy') ?? 0;
    replenishBy = ReplenishBy.values.elementAtOrNull(index) ?? ReplenishBy.quantity;
    controller = TextEditingController(text: widget.ingredient.restockLastPrice?.toShortString() ?? '');
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void switchMethod() async {
    final other = replenishBy == ReplenishBy.quantity ? ReplenishBy.price : ReplenishBy.quantity;
    setState(() {
      replenishBy = other;
    });
    await Cache.instance.set('stock.replenishBy', other.index);
  }
}

enum _Actions {
  delete,
  edit,
}
