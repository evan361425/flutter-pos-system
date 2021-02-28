import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/models.dart';
import 'package:provider/provider.dart';

class ProductModal extends StatefulWidget {
  ProductModal({Key key, @required this.product}) : super(key: key);

  final ProductModel product;

  @override
  _ProductModalState createState() => _ProductModalState();
}

class _ProductModalState extends State<ProductModal> {
  final _formKey = GlobalKey<FormState>();
  bool isSaving = false;
  TextEditingController _nameController;
  TextEditingController _priceController;
  TextEditingController _costController;
  CatalogModel catalog;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(Icons.arrow_back_ios_sharp),
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: isSaving
            ? CircularProgressIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text('儲存'),
                onPressed: () => _onSubmit(_nameController.text),
              ),
      ),
      child: SafeArea(
        child: Material(
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Center(child: _form()),
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit(String value) async {
    if (_formKey.currentState.validate()) {
      setState(() => isSaving = true);
      if (widget.product.isReady) {
        await catalog[widget.product.name].update(
          context,
          name: _nameController.text,
          price: num.parse(_priceController.text),
          cost: num.parse(_costController.text),
        );
      } else {
        await catalog.add(
          ProductModel(
            _nameController.text,
            index: catalog.length,
            catalogName: catalog.name,
            price: num.parse(_priceController.text),
            cost: num.parse(_costController.text),
          ),
          context,
        );
      }
      Navigator.of(context).pop();
    }
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _nameField(),
          SizedBox(height: defaultMargin),
          _priceField(),
          SizedBox(height: defaultMargin),
          _costField(),
        ],
      ),
    );
  }

  Widget _nameField() {
    return TextFormField(
      controller: _nameController,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: '產品名稱，起司漢堡',
        filled: false,
        errorStyle: TextStyle(color: colorNegative),
      ),
      maxLength: 30,
      validator: (String value) {
        final errorMsg = Validator.textLimit('產品名稱', 30)(value);
        if (errorMsg != null) return errorMsg;
        if (value != widget.product.name && catalog.has(value)) return '產品名稱重複';
        return null;
      },
    );
  }

  Widget _priceField() {
    return TextFormField(
      controller: _priceController,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '產品價格，給客人看的價錢',
        filled: false,
        errorStyle: TextStyle(color: colorNegative),
      ),
      validator: Validator.positiveDouble('產品價格'),
    );
  }

  Widget _costField() {
    return TextFormField(
      controller: _costController,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '產品成本，幫助你算出利潤',
        filled: false,
        errorStyle: TextStyle(color: colorNegative),
      ),
      onFieldSubmitted: _onSubmit,
      validator: Validator.positiveDouble('產品成本'),
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _costController =
        TextEditingController(text: widget.product.cost.toString());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    catalog = context.read<MenuModel>()[widget.product.catalogName];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _costController.dispose();
    super.dispose();
  }
}
