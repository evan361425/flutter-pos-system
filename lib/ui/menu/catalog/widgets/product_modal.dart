import 'package:flutter/material.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class ProductModal extends StatefulWidget {
  final Product? product;
  final Catalog catalog;
  final bool isNew;

  const ProductModal({
    Key? key,
    this.product,
    required this.catalog,
  })  : isNew = product == null,
        super(key: key);

  @override
  _ProductModalState createState() => _ProductModalState();
}

class _ProductModalState extends State<ProductModal>
    with ItemModal<ProductModal> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _costController;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  List<Widget> formFields() {
    return [
      TextFormField(
        controller: _nameController,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        autofocus: true,
        decoration: InputDecoration(
          labelText: tt('menu.product.label.name'),
          hintText: tt('menu.product.hint.name'),
          errorText: errorMessage,
          filled: false,
        ),
        maxLength: 30,
        validator: Validator.textLimit(tt('menu.product.label.name'), 30),
      ),
      TextFormField(
        controller: _priceController,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: tt('menu.product.label.price'),
          hintText: tt('menu.product.hint.price'),
          filled: false,
        ),
        validator: Validator.isNumber(tt('menu.product.label.price')),
      ),
      TextFormField(
        controller: _costController,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: tt('menu.product.label.cost'),
          hintText: tt('menu.product.hint.cost'),
          filled: false,
        ),
        onFieldSubmitted: (_) => handleSubmit(),
        validator: Validator.positiveNumber(tt('menu.product.label.cost')),
      ),
    ];
  }

  Future<Product> getProduct() async {
    final object = _parseObject();

    if (widget.isNew) {
      final product = Product(
        catalog: widget.catalog,
        index: widget.catalog.newIndex,
        name: object.name!,
        price: object.price!,
        cost: object.cost!,
      );

      await widget.catalog.setItem(product);
      return product;
    } else {
      await widget.product!.update(object);
      return widget.product!;
    }
  }

  @override
  void initState() {
    super.initState();

    final p = widget.product;
    _nameController = TextEditingController(text: p?.name);
    _priceController = TextEditingController(text: p?.price.toString());
    _costController = TextEditingController(text: p?.cost.toString());
  }

  @override
  Future<void> updateItem() async {
    final product = await getProduct();

    // go to product screen
    widget.isNew
        ? Navigator.of(context).popAndPushNamed(
            Routes.menuProduct,
            arguments: product,
          )
        : Navigator.of(context).pop();
  }

  @override
  String? validate() {
    final name = _nameController.text;

    if (widget.product?.name != name && Menu.instance.hasProductByName(name)) {
      return tt('menu.product.error.name');
    }
  }

  ProductObject _parseObject() {
    return ProductObject(
      name: _nameController.text,
      price: num.tryParse(_priceController.text),
      cost: num.tryParse(_costController.text),
    );
  }
}
