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
  late TextEditingController nameController;
  late TextEditingController amountController;
  late TextEditingController totalAmountController;
  final _nameFocusNode = FocusNode();
  final _amountFocusNode = FocusNode();
  final _totalAmountFocusNode = FocusNode();

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
                onTap: () => handleProductTap(product),
              );
          }
        });
  }

  @override
  List<Widget> buildFormFields() => <Widget>[
        p(TextFormField(
          key: const Key('stock.ingredient.name'),
          controller: nameController,
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
          controller: amountController,
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
          controller: totalAmountController,
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
      ];

  @override
  void initState() {
    super.initState();

    final amount = widget.ingredient?.currentAmount.toAmountString() ?? '';
    final totalAmount = widget.ingredient?.totalAmount?.toAmountString() ?? '';

    nameController = TextEditingController(text: widget.ingredient?.name);
    amountController = TextEditingController(text: amount);
    totalAmountController = TextEditingController(text: totalAmount);
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    totalAmountController.dispose();
    _nameFocusNode.dispose();
    _amountFocusNode.dispose();
    _totalAmountFocusNode.dispose();
    super.dispose();
  }

  @override
  Future<void> updateItem() async {
    final object = parseObject();

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

  void handleProductTap(Product product) {
    context.pushNamed(
      Routes.menuProductModal,
      pathParameters: {'id': product.id},
    );
  }

  IngredientObject parseObject() {
    final amount = num.tryParse(amountController.text) ?? 0;
    return IngredientObject(
      name: nameController.text,
      currentAmount: amount,
      totalAmount: num.tryParse(totalAmountController.text),
      fromModal: true,
    );
  }
}
