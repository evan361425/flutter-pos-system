import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/scaffold/item_modal.dart';
import 'package:possystem/components/style/card_info_text.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/translator.dart';

class StockIngredientRestockModal extends StatefulWidget {
  final Ingredient ingredient;

  const StockIngredientRestockModal({super.key, required this.ingredient});

  @override
  State<StockIngredientRestockModal> createState() => _ModalState();
}

class _ModalState extends State<StockIngredientRestockModal> with ItemModal<StockIngredientRestockModal> {
  late TextEditingController priceController;
  late TextEditingController quantityController;
  final priceFocusNode = FocusNode();
  final quantityFocusNode = FocusNode();

  @override
  String get title => widget.ingredient.name;

  @override
  List<Widget> buildFormFields() => <Widget>[
        p(CardInfoText(child: Text(S.stockIngredientRestockTitle))),
        p(TextFormField(
          key: const Key('stock.ing_restock.price'),
          controller: priceController,
          focusNode: priceFocusNode,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: S.stockIngredientRestockPriceLabel,
            helperMaxLines: 3,
            filled: false,
          ),
          validator: Validator.positiveNumber(
            S.stockIngredientRestockPriceLabel,
            allowNull: true,
            focusNode: priceFocusNode,
          ),
        )),
        p(TextFormField(
          key: const Key('stock.ing_restock.quantity'),
          controller: quantityController,
          focusNode: quantityFocusNode,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.number,
          onFieldSubmitted: handleFieldSubmit,
          decoration: InputDecoration(
            labelText: S.stockIngredientRestockQuantityLabel,
            helperMaxLines: 5,
            filled: false,
          ),
          validator: Validator.positiveNumber(
            S.stockIngredientRestockQuantityLabel,
            allowNull: true,
            focusNode: quantityFocusNode,
          ),
        )),
      ];

  @override
  void initState() {
    super.initState();

    final rp = widget.ingredient.restockPrice?.toShortString();
    final rq = widget.ingredient.restockQuantity.toShortString();

    priceController = TextEditingController(text: rp);
    quantityController = TextEditingController(text: rq);
  }

  @override
  void dispose() {
    priceController.dispose();
    quantityController.dispose();
    priceFocusNode.dispose();
    quantityFocusNode.dispose();
    super.dispose();
  }

  @override
  Future<void> updateItem() async {
    final object = parseObject();

    await widget.ingredient.update(object);

    if (mounted && context.canPop()) {
      context.pop();
    }
  }

  IngredientObject parseObject() {
    return IngredientObject(
      restockPrice: num.tryParse(priceController.text),
      restockQuantity: num.tryParse(quantityController.text),
      fromModal: true,
    );
  }
}
