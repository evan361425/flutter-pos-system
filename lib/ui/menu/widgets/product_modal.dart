import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/scaffold/item_modal.dart';
import 'package:possystem/components/style/image_holder.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/translator.dart';

class ProductModal extends StatefulWidget {
  final Product? product;
  final Catalog catalog;
  final bool isNew;

  const ProductModal({
    super.key,
    this.product,
    required this.catalog,
  }) : isNew = product == null;

  @override
  State<ProductModal> createState() => _ProductModalState();
}

class _ProductModalState extends State<ProductModal> with ItemModal<ProductModal> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _costController;
  late FocusNode _nameFocusNode;
  late FocusNode _priceFocusNode;
  late FocusNode _costFocusNode;

  String? _image;

  @override
  String get title => widget.isNew ? S.menuProductTitleCreate : S.menuProductTitleUpdate;

  @override
  List<Widget> buildFormFields() {
    return [
      EditImageHolder(
        path: _image,
        onSelected: (image) => setState(() => _image = image),
      ),
      p(TextFormField(
        key: const Key('product.name'),
        controller: _nameController,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        focusNode: _nameFocusNode,
        decoration: InputDecoration(
          labelText: S.menuProductNameLabel,
          hintText: widget.product?.name ?? S.menuProductNameHint,
          filled: false,
        ),
        maxLength: 30,
        validator: Validator.textLimit(
          S.menuProductNameLabel,
          30,
          focusNode: _nameFocusNode,
          validator: (name) {
            return widget.product?.name != name && Menu.instance.hasProductByName(name)
                ? S.menuProductNameErrorRepeat
                : null;
          },
        ),
      )),
      p(TextFormField(
        key: const Key('product.price'),
        controller: _priceController,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.number,
        focusNode: _priceFocusNode,
        decoration: InputDecoration(
          labelText: S.menuProductPriceLabel,
          helperText: S.menuProductPriceHelper,
          filled: false,
        ),
        validator: Validator.isNumber(
          S.menuProductPriceLabel,
          focusNode: _priceFocusNode,
        ),
      )),
      p(TextFormField(
        key: const Key('product.cost'),
        controller: _costController,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.number,
        focusNode: _costFocusNode,
        decoration: InputDecoration(
          labelText: S.menuProductCostLabel,
          helperText: S.menuProductCostHelper,
          filled: false,
        ),
        onFieldSubmitted: handleFieldSubmit,
        validator: Validator.positiveNumber(
          S.menuProductCostLabel,
          focusNode: _costFocusNode,
        ),
      )),
    ];
  }

  Future<Product> getProduct() async {
    final object = _parseObject();
    final product = widget.product ??
        Product(
          index: widget.catalog.newIndex,
          name: object.name!,
          price: object.price!,
          cost: object.cost!,
          imagePath: _image,
        );

    if (widget.isNew) {
      await widget.catalog.addItem(product);
    } else {
      await product.update(object);
    }

    return product;
  }

  @override
  void initState() {
    super.initState();

    final p = widget.product;
    _nameController = TextEditingController(text: p?.name);
    _priceController = TextEditingController(text: p?.price.toString());
    _costController = TextEditingController(text: p?.cost.toString());
    _nameFocusNode = FocusNode();
    _priceFocusNode = FocusNode();
    _costFocusNode = FocusNode();
    _image = widget.product?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _nameFocusNode.dispose();
    _priceFocusNode.dispose();
    _costFocusNode.dispose();
    super.dispose();
  }

  @override
  Future<void> updateItem() async {
    final product = await getProduct();

    if (mounted) {
      context.pop(product.id);
    }
  }

  ProductObject _parseObject() {
    return ProductObject(
      name: _nameController.text,
      imagePath: _image,
      price: num.tryParse(_priceController.text),
      cost: num.tryParse(_costController.text),
    );
  }
}
