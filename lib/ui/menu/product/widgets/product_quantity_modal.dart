import 'package:flutter/material.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/components/scaffold/search_scaffold.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/components/style/search_bar_inline.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/stock/quantity/widgets/quantity_modal.dart';
import 'package:provider/provider.dart';

class ProductQuantityModal extends StatefulWidget {
  final ProductQuantity? quantity;
  final ProductIngredient ingredient;

  final bool isNew;

  const ProductQuantityModal({
    Key? key,
    this.quantity,
    required this.ingredient,
  })  : isNew = quantity == null,
        super(key: key);

  @override
  _ProductQuantityModalState createState() => _ProductQuantityModalState();
}

class _ProductQuantityModalState extends State<ProductQuantityModal>
    with ItemModal<ProductQuantityModal> {
  late TextEditingController _amountController;
  late TextEditingController _priceController;
  late TextEditingController _costController;

  String quantityName = '';
  String quantityId = '';

  @override
  Widget? get title =>
      Text(widget.isNew ? S.menuQuantityCreate : widget.quantity!.name);

  @override
  void dispose() {
    _amountController.dispose();
    _priceController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  List<Widget> formFields() {
    return [
      SearchBarInline(
        key: const Key('product_quantity.search'),
        text: quantityName,
        labelText: S.menuQuantitySearchLabel,
        hintText: S.menuQuantitySearchHint,
        errorText: errorMessage,
        helperText: S.menuQuantitySearchHelper,
        onTap: _selectQuantity,
      ),
      TextFormField(
        key: const Key('product_quantity.amount'),
        controller: _amountController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: S.menuQuantityAmountLabel,
          filled: false,
        ),
        validator: Validator.positiveNumber(S.menuQuantityAmountLabel),
      ),
      TextFormField(
        key: const Key('product_quantity.price'),
        controller: _priceController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.loyalty_sharp),
          labelText: S.menuQuantityAdditionalPriceLabel,
          helperText: S.menuQuantityAdditionalPriceHelper,
          helperMaxLines: 10,
          filled: false,
        ),
        validator: Validator.isNumber(S.menuQuantityAdditionalPriceLabel),
      ),
      TextFormField(
        key: const Key('product_quantity.cost'),
        controller: _costController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => handleSubmit(),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.attach_money_sharp),
          labelText: S.menuQuantityAdditionalCostLabel,
          helperText: S.menuQuantityAdditionalCostHelper,
          helperMaxLines: 10,
          filled: false,
        ),
        validator: Validator.isNumber(S.menuQuantityAdditionalCostLabel),
      )
    ];
  }

  @override
  void initState() {
    super.initState();

    final q = widget.quantity;
    _amountController =
        TextEditingController(text: q?.amount.toString() ?? '0');
    _priceController =
        TextEditingController(text: q?.additionalPrice.toString() ?? '0');
    _costController =
        TextEditingController(text: q?.additionalCost.toString() ?? '0');

    if (q != null) {
      quantityId = q.quantity.id;
      quantityName = q.name;
    }
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

    Navigator.of(context).pop();
  }

  @override
  String? validate() {
    if (quantityId.isEmpty) {
      return S.menuQuantitySearchEmptyError;
    }
    if (widget.quantity?.quantity.id != quantityId &&
        widget.ingredient.hasQuantity(quantityId)) {
      return S.menuQuantityRepeatError;
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

  Future<void> _selectQuantity(BuildContext context) async {
    final result = await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _ProductQuantitySearch(quantityName),
    ));

    if (result is Quantity) {
      setState(() {
        errorMessage = null;
        quantityId = result.id;
        quantityName = result.name;
        _updateByProportion(result.defaultProportion);
      });
    }
  }

  void _updateByProportion(num proportion) {
    _amountController.text = (widget.ingredient.amount * proportion).toString();
  }
}

class _ProductQuantitySearch extends StatelessWidget {
  final String? text;

  const _ProductQuantitySearch(this.text);

  @override
  Widget build(BuildContext context) {
    final quantities = context.watch<Quantities>();

    return SearchScaffold<Quantity>(
      handleChanged: (text) async => quantities.sortBySimilarity(text),
      itemBuilder: itemBuilder,
      emptyBuilder: emptyBuilder,
      initialData: quantities.itemList,
      text: text ?? '',
      hintText: S.menuQuantitySearchLabel,
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget emptyBuilder(BuildContext context, String text) {
    return CardTile(
      key: const Key('product_quantity.add_quantity'),
      title: Text(S.menuQuantitySearchAdd(text)),
      onTap: () async {
        final quantity = Quantity(name: text);
        await Quantities.instance.addItem(quantity);
        Navigator.of(context).pop<Quantity>(quantity);
      },
    );
  }

  Widget itemBuilder(BuildContext context, Quantity quantity) {
    return CardTile(
      title: Text(quantity.name),
      trailing: IconButton(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => QuantityModal(quantity))),
        icon: const Icon(Icons.open_in_new_sharp),
      ),
      onTap: () {
        Navigator.of(context).pop<Quantity>(quantity);
      },
    );
  }
}
