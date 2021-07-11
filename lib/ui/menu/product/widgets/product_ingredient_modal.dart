import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/components/style/search_bar_inline.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class ProductIngredientModal extends StatefulWidget {
  final ProductIngredientModel? ingredient;
  final ProductModel product;

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

class _ProductIngredientModalState extends State<ProductIngredientModal>
    with ItemModal<ProductIngredientModal> {
  final _amountController = TextEditingController();

  String ingredientId = '';
  String ingredientName = '';

  @override
  List<Widget> get actions => widget.isNew
      ? const []
      : [
          IconButton(
            onPressed: () async {
              final result = await showCircularBottomSheet<String>(
                context,
                actions: [
                  ListTile(
                    title: Text(tt('delete')),
                    leading: Icon(KIcons.delete, color: kNegativeColor),
                    onTap: () => Navigator.of(context).pop('delete'),
                  ),
                ],
              );

              await _actionHandlers(result);
            },
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
          filled: false,
        ),
        validator: Validator.positiveNumber(tt('menu.ingredient.label.amount')),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();

    if (!widget.isNew) {
      _amountController.text = widget.ingredient!.amount.toString();
      ingredientId = widget.ingredient!.id;
      ingredientName = widget.ingredient!.name;
    }
  }

  @override
  Future<void> updateItem() async {
    final object = _parseObject();

    if (!widget.isNew) {
      await widget.ingredient!.update(object);
    } else {
      final ingredient = ProductIngredientModel(
        ingredient: StockModel.instance.getItem(ingredientId),
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

  Future<void> _actionHandlers(String? selected) {
    switch (selected) {
      case 'delete':
        return _handleDelete();
      default:
        return Future.value();
    }
  }

  Future<void> _handleDelete() async {
    final isDeleted = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return DeleteDialog(
          content:
              Text(tt('delete_confirm', {'name': widget.ingredient!.name})),
          onDelete: (_) => widget.ingredient!.remove(),
        );
      },
    );

    if (isDeleted == true) Navigator.of(context).pop();
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

    if (result is IngredientModel) {
      final ingredient = result;

      setState(() {
        errorMessage = null;
        ingredientId = ingredient.id;
        ingredientName = ingredient.name;
      });
    }
  }
}
