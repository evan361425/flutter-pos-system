import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/slider_text_dialog.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/percentile_bar.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';

class StockIngredientList extends StatelessWidget {
  final List<Ingredient> ingredients;

  const StockIngredientList({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    final updatedAt = latestUpdatedAt();

    return Column(
      children: [
        Center(
          child: HintText([
            updatedAt == null ? S.stockReplenishmentNever : S.stockUpdatedAt(updatedAt),
            S.totalCount(ingredients.length),
          ].join(MetaBlock.string)),
        ),
        const SizedBox(height: 2.0),
        for (final item in ingredients) _IngredientTile(item),
      ],
    );
  }

  DateTime? latestUpdatedAt() {
    DateTime? latest;
    for (var ingredient in ingredients) {
      if (latest == null) {
        latest = ingredient.updatedAt;
      } else if (ingredient.updatedAt?.isAfter(latest) == true) {
        latest = ingredient.updatedAt;
      }
    }

    return latest;
  }
}

class _IngredientTile extends StatelessWidget {
  final Ingredient ingredient;

  const _IngredientTile(this.ingredient);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key('stock.${ingredient.id}'),
      title: Text(ingredient.name),
      subtitle: PercentileBar(ingredient.currentAmount, ingredient.maxAmount),
      onLongPress: () => showActions(context),
      onTap: () => editAmount(context),
      trailing: IconButton(
        key: Key('stock.${ingredient.id}.edit'),
        tooltip: S.stockIngredientTitleUpdate,
        onPressed: () => editIngredient(context),
        icon: const Icon(KIcons.edit),
      ),
    );
  }

  void editIngredient(BuildContext context) {
    context.pushNamed(
      Routes.ingredientModal,
      pathParameters: {'id': ingredient.id},
    );
  }

  void showActions(BuildContext context) async {
    final count = Menu.instance.getIngredients(ingredient.id).length;
    final more = S.stockIngredientDialogDeletionContent(count);

    final result = await BottomSheetActions.withDelete<_Actions>(
      context,
      deleteValue: _Actions.delete,
      warningContent: Text(S.dialogDeletionContent(ingredient.name, '$more\n\n')),
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
          route: Routes.ingredientModal,
          routePathParameters: {'id': ingredient.id},
        ),
      ],
    );

    if (result == _Actions.edit && context.mounted) {
      editAmount(context);
    }
  }

  Future<void> delete() async {
    await ingredient.remove();
    return Menu.instance.removeIngredients(ingredient.id);
  }

  Future<void> editAmount(BuildContext context) async {
    final result = await showAdaptiveDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final controller = TextEditingController(text: ingredient.replenishLastPrice?.toAmountString() ?? '');
        return SliderTextDialog(
          title: Text(ingredient.name),
          value: ingredient.currentAmount.toDouble(),
          max: ingredient.maxAmount,
          builder: (child, onSubmit) => _DialogTabView(
            ingredient: ingredient,
            quantityTab: child,
            onSubmit: onSubmit,
            controller: controller,
          ),
          confirmController: controller,
          decoration: InputDecoration(
            label: Text(S.stockIngredientReplenishDialogQuantityLabel),
            helperText: S.stockIngredientReplenishDialogQuantityHelper,
            helperMaxLines: 3,
          ),
          validator: Validator.positiveNumber(S.stockIngredientReplenishDialogQuantityLabel),
        );
      },
    );

    if (result != null) {
      await ingredient.setAmount(num.tryParse(result) ?? 0);
    }
  }
}

class _DialogTabView extends StatefulWidget {
  final Ingredient ingredient;

  final Widget quantityTab;

  final void Function(String?) onSubmit;

  final TextEditingController controller;

  const _DialogTabView({
    required this.ingredient,
    required this.onSubmit,
    required this.controller,
    required this.quantityTab,
  });

  @override
  State<_DialogTabView> createState() => _DialogTabViewState();
}

class _DialogTabViewState extends State<_DialogTabView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(controller: _tabController, tabs: [
          Tab(key: const Key('stock.repl.quantity'), text: S.stockIngredientReplenishDialogQuantityTab),
          Tab(key: const Key('stock.repl.price'), text: S.stockIngredientReplenishDialogPriceTab),
        ]),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              widget.quantityTab,
              if (widget.ingredient.replenishPrice == null)
                Center(
                  child: EmptyBody(
                    content: S.stockIngredientReplenishDialogPriceEmptyBody,
                    routeName: Routes.ingredientModal,
                    pathParameters: {'id': widget.ingredient.id},
                  ),
                )
              else
                buildPriceTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildPriceTab() {
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      TextFormField(
        key: const Key('stock.repl.price.text'),
        controller: widget.controller,
        onSaved: widget.onSubmit,
        onFieldSubmitted: widget.onSubmit,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(label: Text(S.stockIngredientReplenishDialogPriceLabel)),
        validator: Validator.positiveNumber(S.stockIngredientReplenishDialogPriceLabel),
        textInputAction: TextInputAction.done,
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('÷', style: TextStyle(color: Colors.grey, inherit: true)),
        Text(widget.ingredient.replenishPrice!.toAmountString()),
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('x', style: TextStyle(color: Colors.grey, inherit: true)),
        Text(widget.ingredient.replenishQuantity.toAmountString()),
      ]),
      const Divider(),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          S.stockIngredientReplenishDialogPriceCalculatedQuantityPrefix,
          style: const TextStyle(color: Colors.grey, inherit: true),
        ),
        ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final price = num.tryParse(widget.controller.text);
            if (price == null) return const SizedBox(width: 4.0);

            final quantity = price / widget.ingredient.replenishPrice! * widget.ingredient.replenishQuantity;
            return Text(quantity.toAmountString());
          },
        ),
      ]),
    ]);
  }

  @override
  void initState() {
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: Cache.instance.get<int>('stock.replenishBy') ?? 0,
    );
    _tabController.addListener(() {
      Cache.instance.set('stock.replenishBy', _tabController.index);
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    widget.controller.dispose();
    super.dispose();
  }
}

enum _Actions {
  delete,
  edit,
}
