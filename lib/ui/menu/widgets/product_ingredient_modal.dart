import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/components/search_bar_wrapper.dart';
import 'package:possystem/components/style/more_button.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
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
      SearchBarWrapper(
        key: const Key('product_ingredient.search'),
        text: ingredientName,
        labelText: S.menuIngredientSearchLabel,
        hintText: S.menuIngredientSearchHint,
        // TODO: merge into one validator, and custom [initData]
        validator: Validator.textLimit(S.menuIngredientSearchLabel, 30),
        formValidator: _validateIngredient,
        initData: Stock.instance.itemList,
        search: (text) async => Stock.instance.sortBySimilarity(text),
        itemBuilder: _searchItemBuilder,
        emptyBuilder: _searchEmptyBuilder,
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final stock = context.watch<Stock>();
    final ing = stock.getItem(ingredientId);
    if (ing != null && mounted) {
      setState(() {
        ingredientName = ing.name;
      });
    }
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
      context.pop();
    }
  }

  ProductIngredientObject _parseObject() {
    return ProductIngredientObject(
      ingredientId: ingredientId,
      amount: num.tryParse(_amountController.text),
    );
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

  Widget _searchEmptyBuilder(BuildContext context, String text) {
    return ListTile(
      key: const Key('product_ingredient.add_ingredient'),
      title: Text(S.menuIngredientSearchAdd(text)),
      subtitle: Text(S.menuIngredientSearchHelper),
      onTap: () async {
        final ingredient = Ingredient(name: text);
        await Stock.instance.addItem(ingredient);
        if (context.mounted) {
          _updateIngredient(context, ingredient);
        }
      },
    );
  }

  Widget _searchItemBuilder(BuildContext context, Ingredient ingredient) {
    return ListTile(
      key: Key('product_ingredient.search.${ingredient.id}'),
      title: Text(ingredient.name),
      trailing: NavToButton(
        onPressed: () {
          // pop off search page
          Navigator.of(context).pop();
          context.pushNamed(
            Routes.ingredientModal,
            pathParameters: {'id': ingredient.id},
          );
        },
      ),
      onTap: () => _updateIngredient(context, ingredient),
    );
  }

  void _updateIngredient(BuildContext context, Ingredient ingredient) {
    setState(() {
      ingredientId = ingredient.id;
      ingredientName = ingredient.name;
    });
    // pop off search page
    Navigator.of(context).pop();
  }
}
