import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/ui/menu/menu_routes.dart';
import 'package:provider/provider.dart';

class ProductModal extends StatefulWidget {
  final ProductModel? product;

  ProductModal({Key? key, required this.product}) : super(key: key);
  bool get isNew => product == null;

  @override
  _ProductModalState createState() => _ProductModalState();
}

class _ProductModalState extends State<ProductModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();

  bool isSaving = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
        actions: [
          TextButton(onPressed: () => _handleSubmit(), child: Text('儲存')),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(kSpacing3),
          child: Center(child: _form()),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _costController.dispose();
    super.dispose();
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

  Widget _fieldCost() {
    return TextFormField(
      controller: _costController,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '產品成本，幫助你算出利潤',
        filled: false,
      ),
      onFieldSubmitted: (_) => _handleSubmit(),
      validator: Validator.positiveNumber('產品成本'),
    );
  }

  Widget _fieldName() {
    return TextFormField(
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
    );
  }

  Widget _fieldPrice() {
    return TextFormField(
      controller: _priceController,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '產品價格，給客人看的價錢',
        filled: false,
      ),
      validator: Validator.positiveNumber('產品價格'),
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _fieldName(),
          const SizedBox(height: kSpacing2),
          _fieldPrice(),
          const SizedBox(height: kSpacing2),
          _fieldCost(),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_validate()) return;

    final product = await _updateProduct();

    // go to product screen
    widget.isNew
        ? Navigator.of(context).popAndPushNamed(
            MenuRoutes.product,
            arguments: product,
          )
        : Navigator.of(context).pop();
  }

  ProductObject _parseObject() {
    return ProductObject(
      name: _nameController.text,
      price: num.tryParse(_priceController.text),
      cost: num.tryParse(_costController.text),
    );
  }

  Future<ProductModel> _updateProduct() async {
    final object = _parseObject();

    if (widget.isNew) {
      final catalog = context.read<CatalogModel>();
      final product = ProductModel(
        catalog: catalog,
        index: catalog.newIndex,
        name: object.name!,
        price: object.price!,
        cost: object.cost!,
      );

      await catalog.setProduct(product);
      return product;
    } else {
      await widget.product!.update(object);
      return widget.product!;
    }
  }

  bool _validate() {
    if (isSaving || !_formKey.currentState!.validate()) return false;

    final name = _nameController.text;

    if (widget.product?.name != name && MenuModel.instance.hasProduct(name)) {
      setState(() => errorMessage = '產品名稱重複');
      return false;
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    return true;
  }
}
