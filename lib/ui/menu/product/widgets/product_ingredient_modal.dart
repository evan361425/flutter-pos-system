import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/components/style/search_bar_inline.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class ProductIngredientModal extends StatefulWidget {
  final ProductIngredient? ingredient;
  final Product product;

  final bool isNew;

  ProductIngredientModal({
    Key? key,
    this.ingredient,
    required this.product,
  })  : isNew = ingredient == null,
        super(key: key);

  @override
  _ProductIngredientModalState createState() => _ProductIngredientModalState();
}

enum _Actions {
  delete,
}

class _ProductIngredientModalState extends State<ProductIngredientModal>
    with ItemModal<ProductIngredientModal> {
  late TextEditingController _amountController;

  String ingredientId = '';
  String ingredientName = '';

  @override
  List<Widget> get actions => widget.isNew
      ? const []
      : [
          IconButton(
            onPressed: () => BottomSheetActions.withDelete<_Actions>(
              context,
              deleteValue: _Actions.delete,
              warningContent:
                  Text(tt('delete_confirm', {'name': widget.ingredient!.name})),
              popAfterDeleted: true,
              deleteCallback: widget.ingredient!.remove,
            ),
            icon: Icon(KIcons.more),
          ),
        ];

  @override
  Widget? get title => Text(tt(
      widget.isNew ? 'menu.ingredient.add_title' : 'menu.ingredient.edit_title',
      {'name': widget.ingredient?.name ?? ''}));

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  List<Widget> formFields() {
    return [
      SearchBarInline(
        text: ingredientName,
        labelText: tt('menu.ingredient.label.name'),
        hintText: tt('menu.ingredient.hint.name'),
        errorText: errorMessage,
        helperText: tt('menu.ingredient.helper.name'),
        onTap: _selectIngredient,
      ),
      TextFormField(
        controller: _amountController,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => handleSubmit(),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: tt('menu.ingredient.label.amount'),
          helperText: tt('menu.ingredient.helper.amount'),
          helperMaxLines: 10,
          filled: false,
        ),
        validator: Validator.positiveNumber(tt('menu.ingredient.label.amount')),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();

    final i = widget.ingredient;

    _amountController = TextEditingController(text: i?.amount.toString());
    if (i != null) {
      ingredientId = i.id;
      ingredientName = i.name;
    }
  }

  @override
  Future<void> updateItem() async {
    final object = _parseObject();

    if (!widget.isNew) {
      await widget.ingredient!.update(object);
    } else {
      final ingredient = ProductIngredient(
        ingredient: Stock.instance.getItem(ingredientId),
        product: widget.product,
        amount: object.amount!,
      );

      await widget.product.setItem(ingredient);
    }

    Navigator.of(context).pop();
  }

  @override
  String? validate() {
    if (ingredientId.isEmpty) {
      return tt('menu.ingredient.error.name_empty');
    }
    if (widget.ingredient?.id != ingredientId &&
        widget.product.hasItem(ingredientId)) {
      return tt('menu.ingredient.error.name_repeat');
    }
  }

  ProductIngredientObject _parseObject() {
    return ProductIngredientObject(
      id: ingredientId,
      amount: num.tryParse(_amountController.text),
    );
  }

  Future<void> _selectIngredient(BuildContext context) async {
    final result = await Navigator.of(context).pushNamed(
      Routes.menuIngredientSearch,
      arguments: ingredientName,
    );

    if (result is Ingredient) {
      final ingredient = result;

      setState(() {
        errorMessage = null;
        ingredientId = ingredient.id;
        ingredientName = ingredient.name;
      });
    }
  }
}
