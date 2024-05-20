import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/scaffold/item_modal.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class StockIngredientModal extends StatefulWidget {
  final Ingredient? ingredient;

  final bool isNew;

  const StockIngredientModal({super.key, this.ingredient}) : isNew = ingredient == null;

  @override
  State<StockIngredientModal> createState() => _StockIngredientModalState();
}

class _StockIngredientModalState extends State<StockIngredientModal> with ItemModal<StockIngredientModal> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _totalAmountController;
  late TextEditingController _groupCostAmountController;
  late TextEditingController _groupAmountAmountController;
  final _nameFocusNode = FocusNode();
  final _amountFocusNode = FocusNode();
  final _totalAmountFocusNode = FocusNode();
  final _groupCostFocusNode = FocusNode();
  final _groupAmountFocusNode = FocusNode();

  @override
  String get title => widget.ingredient?.name ?? S.stockIngredientTitleCreate;

  @override
  Widget buildForm() {
    final ingredients =
        widget.isNew ? const <ProductIngredient>[] : Menu.instance.getIngredients(widget.ingredient!.id);
    // +2: 1 for form, 2 for text-divider
    final length = widget.isNew ? 1 : ingredients.length + 2;

    return ListView.builder(
        itemCount: length,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return Form(
                key: formKey,
                child: Column(
                  children: buildFormFields(),
                ),
              );
            case 1:
              return TextDivider(
                label: S.stockIngredientProductsCount(length - 2),
              );
            default:
              final product = ingredients[index - 2].product;
              return ListTile(
                key: Key('stock.ingredient.${product.id}'),
                title: Text(
                  '${product.catalog.name} - ${product.name}',
                ),
                onTap: () => _handleTap(product),
              );
          }
        });
  }

  @override
  List<Widget> buildFormFields() => <Widget>[
        p(TextFormField(
          key: const Key('stock.ingredient.name'),
          controller: _nameController,
          focusNode: _nameFocusNode,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: S.stockIngredientNameLabel,
            hintText: S.stockIngredientNameHint,
            filled: false,
          ),
          maxLength: 30,
          validator: Validator.textLimit(
            S.stockIngredientNameLabel,
            30,
            focusNode: _nameFocusNode,
            validator: (name) {
              return widget.ingredient?.name != name && Stock.instance.hasName(name)
                  ? S.stockIngredientNameErrorRepeat
                  : null;
            },
          ),
        )),
        p(TextFormField(
          key: const Key('stock.ingredient.amount'),
          controller: _amountController,
          focusNode: _amountFocusNode,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: S.stockIngredientAmountLabel,
            filled: false,
          ),
          validator: Validator.positiveNumber(
            S.stockIngredientAmountLabel,
            allowNull: true,
            focusNode: _amountFocusNode,
          ),
        )),
        p(TextFormField(
          key: const Key('stock.ingredient.totalAmount'),
          controller: _totalAmountController,
          focusNode: _totalAmountFocusNode,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: S.stockIngredientAmountMaxLabel,
            helperText: S.stockIngredientAmountMaxHelper,
            helperMaxLines: 6,
            filled: false,
          ),
          validator: Validator.positiveNumber(
            S.stockIngredientAmountMaxLabel,
            allowNull: true,
            focusNode: _totalAmountFocusNode,
          ),
        )),
        p(TextFormField(
          key: const Key('stock.ingredient.groupCost'),
          controller: _groupCostAmountController,
          focusNode: _groupCostFocusNode,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '單位進價',
            helperText: '每次補貨時，每單位的價錢\n方便快速計算補貨',
            helperMaxLines: 3,
            filled: false,
          ),
          validator: Validator.positiveNumber(
            '單位進價',
            allowNull: true,
            focusNode: _groupCostFocusNode,
          ),
        )),
        p(TextFormField(
          key: const Key('stock.ingredient.groupAmount'),
          controller: _groupAmountAmountController,
          focusNode: _groupAmountFocusNode,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.number,
          onFieldSubmitted: handleFieldSubmit,
          decoration: const InputDecoration(
            labelText: '進貨單位',
            helperText: '每次補貨「進貨單位」個成分，就需要「單位進價」的價錢。\n例如，每 30 份起司要價 100 元，\n「進貨單位」就填寫 30，「單位進價」就填寫 100。',
            helperMaxLines: 5,
            filled: false,
          ),
          validator: Validator.positiveNumber(
            S.stockIngredientAmountMaxLabel,
            allowNull: true,
            focusNode: _groupAmountFocusNode,
          ),
        )),
      ];

  @override
  void initState() {
    super.initState();

    final amount = widget.ingredient?.currentAmount.toShortString() ?? '';
    final totalAmount = widget.ingredient?.totalAmount?.toShortString() ?? '';
    final groupCost = widget.ingredient?.groupCost?.toShortString() ?? '';
    final groupAmount = widget.ingredient?.groupAmount?.toString() ?? '1';

    _nameController = TextEditingController(text: widget.ingredient?.name);
    _amountController = TextEditingController(text: amount);
    _totalAmountController = TextEditingController(text: totalAmount);
    _groupCostAmountController = TextEditingController(text: groupCost);
    _groupAmountAmountController = TextEditingController(text: groupAmount);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _totalAmountController.dispose();
    _groupCostAmountController.dispose();
    _groupAmountAmountController.dispose();
    _nameFocusNode.dispose();
    _amountFocusNode.dispose();
    _totalAmountFocusNode.dispose();
    _groupCostFocusNode.dispose();
    _groupAmountFocusNode.dispose();
    super.dispose();
  }

  @override
  Future<void> updateItem() async {
    final object = _parseObject();

    if (widget.isNew) {
      await Stock.instance.addItem(Ingredient(
        name: object.name!,
        currentAmount: object.currentAmount!,
        totalAmount: object.totalAmount,
      ));
    } else {
      await widget.ingredient!.update(object);
    }

    if (mounted && context.canPop()) {
      context.pop();
    }
  }

  void _handleTap(Product product) {
    context.pushNamed(
      Routes.menuProductModal,
      pathParameters: {'id': product.id},
    );
  }

  IngredientObject _parseObject() {
    final amount = num.tryParse(_amountController.text) ?? 0;
    return IngredientObject(
      name: _nameController.text,
      lastAmount: amount,
      currentAmount: amount,
      totalAmount: num.tryParse(_totalAmountController.text),
      groupCost: num.tryParse(_groupCostAmountController.text),
      groupAmount: num.tryParse(_groupAmountAmountController.text),
      fromModal: true,
    );
  }
}

extension IntOrDouble on num {
  String toShortString() {
    // if it has decimal, show it, else show int
    final rounded = round();
    if (this == rounded) {
      return rounded.toString();
    }

    return toStringAsFixed(2);
  }
}
