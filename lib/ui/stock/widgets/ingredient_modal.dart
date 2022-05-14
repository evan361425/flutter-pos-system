import 'package:flutter/material.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class IngredientModal extends StatefulWidget {
  final Ingredient? ingredient;

  final bool isNew;

  final bool editable;

  const IngredientModal({Key? key, this.ingredient, this.editable = true})
      : isNew = ingredient == null,
        super(key: key);

  @override
  _IngredientModalState createState() => _IngredientModalState();
}

class _IngredientModalState extends State<IngredientModal>
    with ItemModal<IngredientModal> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;

  @override
  Widget body() {
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
              return super.body();
            case 1:
              return Padding(
                padding: const EdgeInsets.only(bottom: kSpacing2),
                child: Center(
                  child: HintText(S.stockIngredientConnectedProductsCount(
                    length - 2,
                    widget.ingredient!.name,
                  )),
                ),
              );
            default:
              final product = ingredients[index - 2].product;
              return CardTile(
                key: Key('stock.ingredient.${product.id}'),
                title: Text(
                  '${product.catalog.name} - ${product.name}',
                ),
                onTap: widget.editable ? () => _handleTap(product) : null,
              );
          }
        });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  List<Widget> formFields() => <Widget>[
        TextFormField(
          key: const Key('stock.ingredient.name'),
          controller: _nameController,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: S.stockIngredientNameLabel,
            hintText: S.stockIngredientNameHint,
            errorText: errorMessage,
            filled: false,
          ),
          autofocus: widget.isNew,
          maxLength: 30,
          validator: Validator.textLimit(S.stockIngredientNameLabel, 30),
        ),
        TextFormField(
          key: const Key('stock.ingredient.amount'),
          controller: _amountController,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: S.stockIngredientAmountLabel,
            helperText: S.stockIngredientAmountHelper,
            errorText: errorMessage,
            filled: false,
          ),
          validator: Validator.positiveNumber(
            S.stockIngredientAmountLabel,
            allowNull: true,
          ),
        ),
      ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.ingredient?.name);

    final amount = widget.ingredient?.currentAmount?.toString() ?? '';
    _amountController = TextEditingController(text: amount);
  }

  @override
  Future<void> updateItem() async {
    final object = _parseObject();

    if (widget.isNew) {
      await Stock.instance.addItem(Ingredient(
        name: object.name!,
        currentAmount: object.currentAmount!,
      ));
    } else {
      await widget.ingredient!.update(object);
    }

    Navigator.of(context).pop();
  }

  @override
  String? validate() {
    final name = _nameController.text;

    if (widget.ingredient?.name != name && Stock.instance.hasName(name)) {
      return S.stockIngredientNameRepeatError;
    }

    return null;
  }

  void _handleTap(Product product) {
    Navigator.of(context).pushNamed(
      Routes.menuProduct,
      arguments: product,
    );
  }

  IngredientObject _parseObject() {
    return IngredientObject(
      name: _nameController.text,
      currentAmount: num.tryParse(_amountController.text),
    );
  }
}
