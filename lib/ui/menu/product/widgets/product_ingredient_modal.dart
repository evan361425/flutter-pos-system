import 'package:flutter/material.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/components/scaffold/search_scaffold.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/components/style/search_bar_inline.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/stock/widgets/ingredient_modal.dart';
import 'package:provider/provider.dart';

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

class _ProductIngredientModalState extends State<ProductIngredientModal>
    with ItemModal<ProductIngredientModal> {
  late TextEditingController _amountController;

  String ingredientId = '';
  String ingredientName = '';

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
        key: Key('menu.ingredient.search'),
        text: ingredientName,
        labelText: tt('menu.ingredient.label.name'),
        hintText: tt('menu.ingredient.hint.name'),
        errorText: errorMessage,
        helperText: tt('menu.ingredient.helper.name'),
        onTap: _selectIngredient,
      ),
      TextFormField(
        key: Key('menu.ingredient.amount'),
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
      ingredientId = i.ingredient.id;
      ingredientName = i.name;
    }
  }

  @override
  Future<void> updateItem() async {
    final object = _parseObject();

    if (widget.isNew) {
      await widget.product.addItem(ProductIngredient(
        ingredient: Stock.instance.getItem(ingredientId),
        amount: object.amount!,
      ));
    } else {
      await widget.ingredient!.update(object);
    }

    Navigator.of(context).pop();
  }

  @override
  String? validate() {
    if (ingredientId.isEmpty) {
      return tt('menu.ingredient.error.name_empty');
    }
    if (widget.ingredient?.ingredient.id != ingredientId &&
        widget.product.hasIngredient(ingredientId)) {
      return tt('menu.ingredient.error.name_repeat');
    }
  }

  ProductIngredientObject _parseObject() {
    return ProductIngredientObject(
      ingredientId: ingredientId,
      amount: num.tryParse(_amountController.text),
    );
  }

  Future<void> _selectIngredient(BuildContext context) async {
    final result = await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _ProductIngredientSearch(text: ingredientName),
    ));

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

class _ProductIngredientSearch extends StatelessWidget {
  final String? text;

  const _ProductIngredientSearch({Key? key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stock = context.watch<Stock>();

    return SearchScaffold<Ingredient>(
      handleChanged: (text) async {
        return stock.sortBySimilarity(text);
      },
      itemBuilder: itemBuilder,
      emptyBuilder: emptyBuilder,
      initialData: stock.itemList,
      text: text ?? '',
      hintText: tt('menu.ingredient.label.name'),
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget emptyBuilder(BuildContext context, String text) {
    return CardTile(
      title: Text(tt('menu.ingredient.add_ingredient', {'name': text})),
      onTap: () async {
        final ingredient = Ingredient(name: text);
        await Stock.instance.addItem(ingredient);
        Navigator.of(context).pop<Ingredient>(ingredient);
      },
    );
  }

  Widget itemBuilder(BuildContext context, Ingredient ingredient) {
    return CardTile(
      title: Text(ingredient.name),
      trailing: IconButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => IngredientModal(
              ingredient: ingredient,
              editable: false,
            ),
          ));
        },
        icon: Icon(Icons.open_in_new_sharp),
      ),
      onTap: () {
        Navigator.of(context).pop(ingredient);
      },
    );
  }
}
