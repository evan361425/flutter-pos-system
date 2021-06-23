import 'package:flutter/material.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/routes.dart';

class ProductModal extends StatefulWidget {
  final ProductModel? product;
  final CatalogModel catalog;
  final bool isNew;

  ProductModal({
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
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();

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
          labelText: '產品名稱，起司漢堡',
          errorText: errorMessage,
          filled: false,
        ),
        maxLength: 30,
        validator: Validator.textLimit('產品名稱', 30),
      ),
      TextFormField(
        controller: _priceController,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: '產品價格，給客人看的價錢',
          filled: false,
        ),
        validator: Validator.positiveNumber('產品價格'),
      ),
      TextFormField(
        controller: _costController,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: '產品成本，幫助你算出利潤',
          filled: false,
        ),
        onFieldSubmitted: (_) => handleSubmit(),
        validator: Validator.positiveNumber('產品成本'),
      ),
    ];
  }

  Future<ProductModel> getProduct() async {
    final object = _parseObject();

    if (widget.isNew) {
      final product = ProductModel(
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
    if (!widget.isNew) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _costController.text = widget.product!.cost.toString();
    }
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

    if (widget.product?.name != name && MenuModel.instance.hasProduct(name)) {
      return '產品名稱重複';
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
