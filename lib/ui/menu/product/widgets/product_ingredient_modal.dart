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

  const ProductIngredientModal({
    Key? key,
    this.ingredient,
    required this.product,
  })  : isNew = ingredient == null,
        super(key: key);

  @override
  State<ProductIngredientModal> createState() => _ProductIngredientModalState();
}

class _ProductIngredientModalState extends State<ProductIngredientModal>
    with ItemModal<ProductIngredientModal> {
  late TextEditingController _amountController;
  late FocusNode _amountFocusNode;

  String ingredientId = '';
  String ingredientName = '';

  @override
  Widget? get title =>
      Text(widget.isNew ? S.menuIngredientCreate : widget.ingredient!.name);

  @override
  List<Widget> buildFormFields() {
    return [
      SearchBarInline(
        key: const Key('product_ingredient.search'),
        text: ingredientName,
        labelText: S.menuIngredientSearchLabel,
        hintText: S.menuIngredientSearchHint,
        autofocus: widget.isNew,
        validator: _validateIngredient,
        helperText: S.menuIngredientSearchHelper,
        onTap: _selectIngredient,
      ),
      TextFormField(
        key: const Key('product_ingredient.amount'),
        controller: _amountController,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => handleSubmit(),
        keyboardType: TextInputType.number,
        focusNode: _amountFocusNode,
        decoration: InputDecoration(
          labelText: S.menuIngredientAmountLabel,
          helperText: S.menuIngredientAmountHelper,
          helperMaxLines: 10,
          filled: false,
        ),
        validator: Validator.positiveNumber(
          S.menuIngredientAmountLabel,
          focusNode: _amountFocusNode,
        ),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();

    final i = widget.ingredient;

    _amountController = TextEditingController(text: i?.amount.toString());
    _amountFocusNode = FocusNode();

    if (i != null) {
      ingredientId = i.ingredient.id;
      ingredientName = i.name;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
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

    if (mounted) {
      Navigator.of(context).pop();
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
        ingredientId = ingredient.id;
        ingredientName = ingredient.name;
      });
    }
  }

  String? _validateIngredient(String? name) {
    if (ingredientId.isEmpty) {
      return S.menuIngredientSearchEmptyError;
    }

    if (widget.ingredient?.ingredient.id != ingredientId &&
        widget.product.hasIngredient(ingredientId)) {
      return S.menuIngredientRepeatError;
    }

    return null;
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
      hintText: S.menuIngredientSearchLabel,
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget emptyBuilder(BuildContext context, String text) {
    return CardTile(
      key: const Key('product_ingredient.add_ingredient'),
      title: Text(S.menuIngredientSearchAdd(text)),
      onTap: () async {
        final ingredient = Ingredient(name: text);
        await Stock.instance.addItem(ingredient);
        if (context.mounted) {
          Navigator.of(context).pop<Ingredient>(ingredient);
        }
      },
    );
  }

  Widget itemBuilder(BuildContext context, Ingredient ingredient) {
    return CardTile(
      key: Key('product_ingredient.search.${ingredient.id}'),
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
        icon: const Icon(Icons.open_in_new_sharp),
      ),
      onTap: () {
        Navigator.of(context).pop(ingredient);
      },
    );
  }
}
