import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/scaffold/item_modal.dart';
import 'package:possystem/components/search_bar_wrapper.dart';
import 'package:possystem/components/style/buttons.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

class ProductQuantityModal extends StatefulWidget {
  final ProductQuantity? quantity;
  final ProductIngredient ingredient;

  final bool isNew;

  const ProductQuantityModal({
    super.key,
    this.quantity,
    required this.ingredient,
  }) : isNew = quantity == null;

  @override
  State<ProductQuantityModal> createState() => _ProductQuantityModalState();
}

class _ProductQuantityModalState extends State<ProductQuantityModal> with ItemModal<ProductQuantityModal> {
  late TextEditingController _amountController;
  late TextEditingController _priceController;
  late TextEditingController _costController;
  late FocusNode _amountFocusNode;
  late FocusNode _priceFocusNode;
  late FocusNode _costFocusNode;

  String quantityName = '';
  String quantityId = '';

  @override
  String get title => widget.isNew ? S.menuQuantityTitleCreate : S.menuQuantityTitleUpdate;

  @override
  List<Widget> buildFormFields() {
    return [
      // avoid search-bar's label overflow
      const SizedBox(height: 12.0),
      p(SearchBarWrapper(
        key: const Key('product_quantity.search'),
        text: quantityName,
        labelText: S.menuQuantitySearchLabel,
        hintText: widget.quantity?.name ?? S.menuQuantitySearchHint,
        validator: Validator.textLimit(S.menuQuantitySearchLabel, 30),
        formValidator: _validateQuantity,
        initData: Quantities.instance.itemList,
        search: (text) async => Quantities.instance.sortBySimilarity(text),
        itemBuilder: _searchItemBuilder,
        emptyBuilder: _searchEmptyBuilder,
      )),
      p(TextFormField(
        key: const Key('product_quantity.amount'),
        controller: _amountController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        focusNode: _amountFocusNode,
        decoration: InputDecoration(
          labelText: S.menuQuantityAmountLabel,
          filled: false,
        ),
        validator: Validator.positiveNumber(
          S.menuQuantityAmountLabel,
          focusNode: _amountFocusNode,
        ),
      )),
      p(TextFormField(
        key: const Key('product_quantity.price'),
        controller: _priceController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        focusNode: _priceFocusNode,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.loyalty_outlined),
          labelText: S.menuQuantityAdditionalPriceLabel,
          helperText: S.menuQuantityAdditionalPriceHelper,
          helperMaxLines: 10,
          filled: false,
        ),
        validator: Validator.isNumber(
          S.menuQuantityAdditionalPriceLabel,
          focusNode: _priceFocusNode,
        ),
      )),
      p(TextFormField(
        key: const Key('product_quantity.cost'),
        controller: _costController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        focusNode: _costFocusNode,
        onFieldSubmitted: handleFieldSubmit,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.attach_money_outlined),
          labelText: S.menuQuantityAdditionalCostLabel,
          helperText: S.menuQuantityAdditionalCostHelper,
          helperMaxLines: 10,
          filled: false,
        ),
        validator: Validator.isNumber(
          S.menuQuantityAdditionalCostLabel,
          focusNode: _costFocusNode,
        ),
      )),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repo = context.watch<Quantities>();
    final qua = repo.getItem(quantityId);
    if (qua != null && mounted) {
      setState(() {
        quantityName = qua.name;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    final q = widget.quantity;
    _amountController = TextEditingController(text: q?.amount.toString() ?? '0');
    _priceController = TextEditingController(text: q?.additionalPrice.toString() ?? '0');
    _costController = TextEditingController(text: q?.additionalCost.toString() ?? '0');
    _amountFocusNode = FocusNode();
    _priceFocusNode = FocusNode();
    _costFocusNode = FocusNode();

    if (q != null) {
      quantityId = q.quantity.id;
      quantityName = q.name;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _amountFocusNode.dispose();
    _priceFocusNode.dispose();
    _costFocusNode.dispose();
    super.dispose();
  }

  @override
  Future<void> updateItem() async {
    final object = _parseObject();

    if (widget.isNew) {
      await widget.ingredient.addItem(ProductQuantity(
        quantity: Quantities.instance.getItem(quantityId),
        amount: object.amount!,
        additionalPrice: object.additionalPrice!,
        additionalCost: object.additionalCost!,
      ));
    } else {
      await widget.quantity!.update(object);
    }

    if (mounted) {
      context.pop();
    }
  }

  ProductQuantityObject _parseObject() {
    return ProductQuantityObject(
      quantityId: quantityId,
      amount: num.parse(_amountController.text),
      additionalPrice: num.parse(_priceController.text),
      additionalCost: num.parse(_costController.text),
    );
  }

  String? _validateQuantity(String? name) {
    if (quantityId.isEmpty) {
      return S.menuQuantitySearchErrorEmpty;
    }
    if (widget.quantity?.quantity.id != quantityId && widget.ingredient.hasQuantity(quantityId)) {
      return S.menuQuantitySearchErrorRepeat;
    }

    return null;
  }

  Widget _searchEmptyBuilder(BuildContext context, String text) {
    return ListTile(
      key: const Key('product_quantity.add_quantity'),
      title: Text(S.menuQuantitySearchAdd(text)),
      subtitle: Text(S.menuQuantitySearchHelper),
      onTap: () async {
        final quantity = Quantity(name: text);
        await Quantities.instance.addItem(quantity);
        if (context.mounted) {
          _updateQuantity(quantity);
        }
      },
    );
  }

  Widget _searchItemBuilder(BuildContext context, Quantity quantity) {
    return ListTile(
      title: Text(quantity.name),
      trailing: NavToButton(
        onPressed: () {
          // pop off search page
          Navigator.of(context).pop();
          context.pushNamed(
            Routes.quantityUpdate,
            pathParameters: {'id': quantity.id},
          );
        },
      ),
      onTap: () => _updateQuantity(quantity),
    );
  }

  void _updateQuantity(Quantity quantity) {
    final val = widget.ingredient.amount * quantity.defaultProportion;
    setState(() {
      quantityId = quantity.id;
      quantityName = quantity.name;
      _amountController.text = val.toInt() == val ? val.toString() : val.toStringAsFixed(2);
    });
    // pop off search page
    Navigator.of(context).pop();
  }
}
