import 'package:flutter/material.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/custom_styles.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/routes.dart';

class IngredientModal extends StatefulWidget {
  final IngredientModel? ingredient;

  final bool isNew;

  IngredientModal({Key? key, this.ingredient})
      : isNew = ingredient == null,
        super(key: key);

  @override
  _IngredientModalState createState() => _IngredientModalState();
}

class _IngredientModalState extends State<IngredientModal>
    with ItemModal<IngredientModal> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget body() {
    final isReady = MenuModel.instance.setUpStockMode(context);
    final ingredients = !isReady || widget.isNew
        ? const <ProductIngredientModel>[]
        : MenuModel.instance.getIngredients(widget.ingredient!.id);
    // 1 for body, 2 for divider and text
    final length = ingredients.length + 1 + (isReady && widget.isNew ? 0 : 1);

    return ListView.builder(
        itemCount: length,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return super.body();
            case 1:
              return isReady
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: kSpacing2),
                      child: Center(
                        child: Text(
                          '共有${length - 2}個產品使用${widget.ingredient!.name}',
                          style: Theme.of(context).textTheme.muted,
                        ),
                      ),
                    )
                  : CircularLoading();
            default:
              final product = ingredients[index - 2].product;
              return CardTile(
                title: Text(
                  '${product.catalog.name} - ${product.name}',
                ),
                onTap: () => _handleTap(product),
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
          controller: _nameController,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: '成份名稱，起司',
            errorText: errorMessage,
            filled: false,
          ),
          autofocus: widget.ingredient == null,
          maxLength: 30,
          validator: Validator.textLimit('成份名稱', 30),
        ),
        TextFormField(
          controller: _amountController,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '庫存',
            errorText: errorMessage,
            filled: false,
          ),
          validator: Validator.positiveNumber('庫存'),
        ),
      ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.ingredient?.name ?? '';
    _amountController.text = widget.ingredient?.currentAmount?.toString() ?? '';
  }

  @override
  Future<void> updateItem() async {
    final object = _parseObject();

    if (widget.isNew) {
      final ingredient = IngredientModel(
        name: object.name!,
        currentAmount: object.currentAmount!,
      );

      await StockModel.instance.setItem(ingredient);
    } else {
      await widget.ingredient!.update(object);
    }

    Navigator.of(context).pop();
  }

  @override
  String? validate() {
    final name = _nameController.text;

    if (widget.ingredient?.name != name && StockModel.instance.hasItem(name)) {
      return '成份名稱重複';
    }
  }

  void _handleTap(ProductModel product) {
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
