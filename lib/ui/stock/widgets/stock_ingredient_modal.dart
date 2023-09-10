import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/mixin/item_modal.dart';
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

  const StockIngredientModal({Key? key, this.ingredient})
      : isNew = ingredient == null,
        super(key: key);

  @override
  State<StockIngredientModal> createState() => _StockIngredientModalState();
}

class _StockIngredientModalState extends State<StockIngredientModal>
    with ItemModal<StockIngredientModal> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _totalAmountController;
  late FocusNode _nameFocusNode;
  late FocusNode _amountFocusNode;
  late FocusNode _totalAmountFocusNode;

  @override
  Widget buildBody() {
    final ingredients = widget.isNew
        ? const <ProductIngredient>[]
        : Menu.instance.getIngredients(widget.ingredient!.id);
    // 1 for body, 2 for divider and text
    final length = ingredients.length + 1 + (widget.isNew ? 0 : 1);

    return ListView.builder(
        itemCount: length,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return super.buildBody();
            case 1:
              return TextDivider(
                label: S.stockIngredientConnectedProductsCount(
                  length - 2,
                  widget.ingredient!.name,
                ),
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
        TextFormField(
          key: const Key('stock.ingredient.name'),
          controller: _nameController,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.words,
          focusNode: _nameFocusNode,
          decoration: InputDecoration(
            labelText: S.stockIngredientNameLabel,
            hintText: S.stockIngredientNameHint,
            filled: false,
          ),
          autofocus: widget.isNew,
          maxLength: 30,
          validator: Validator.textLimit(
            S.stockIngredientNameLabel,
            30,
            focusNode: _nameFocusNode,
            validator: (name) {
              return widget.ingredient?.name != name &&
                      Stock.instance.hasName(name)
                  ? S.stockIngredientNameRepeatError
                  : null;
            },
          ),
        ),
        TextFormField(
          key: const Key('stock.ingredient.amount'),
          controller: _amountController,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.number,
          focusNode: _amountFocusNode,
          decoration: InputDecoration(
            labelText: S.stockIngredientAmountLabel,
            filled: false,
          ),
          validator: Validator.positiveNumber(
            S.stockIngredientAmountLabel,
            allowNull: true,
            focusNode: _amountFocusNode,
          ),
        ),
        TextFormField(
          key: const Key('stock.ingredient.totalAmount'),
          controller: _totalAmountController,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.number,
          focusNode: _totalAmountFocusNode,
          decoration: InputDecoration(
            labelText: S.stockIngredientTotalAmountLabel,
            helperText: S.stockIngredientTotalAmountHelper,
            helperMaxLines: 5,
            filled: false,
          ),
          validator: Validator.positiveNumber(
            S.stockIngredientTotalAmountLabel,
            allowNull: true,
            focusNode: _totalAmountFocusNode,
          ),
        ),
      ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.ingredient?.name);

    final amount = widget.ingredient?.currentAmount.toString() ?? '';
    final totalAmount = widget.ingredient?.totalAmount?.toString() ?? '';
    _amountController = TextEditingController(text: amount);
    _totalAmountController = TextEditingController(text: totalAmount);

    _nameFocusNode = FocusNode();
    _amountFocusNode = FocusNode();
    _totalAmountFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _totalAmountController.dispose();
    _nameFocusNode.dispose();
    _amountFocusNode.dispose();
    _totalAmountFocusNode.dispose();
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
      fromModal: true,
    );
  }
}
