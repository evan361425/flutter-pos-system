import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/models/product_model.dart';
import 'package:provider/provider.dart';

class ProductName extends StatefulWidget {
  final ProductModel product;
  ProductName(this.product);

  @override
  _ProductNameState createState() => _ProductNameState(product);
}

class _ProductNameState extends State<ProductName> {
  final _key = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  final ProductModel _product;
  _NameStatus _status;

  _ProductNameState(this._product);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: defaultPadding,
        ),
        child: Row(
          children: [
            Expanded(
              child:
                  _status == _NameStatus.fixed ? _buildText() : _buildEditor(),
            ),
            _status == _NameStatus.processing
                ? CircularProgressIndicator()
                : _status == _NameStatus.editing
                    ? IconButton(icon: Icon(Icons.check), onPressed: _save)
                    : IconButton(icon: Icon(Icons.edit), onPressed: _edit),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _status = _product.isReady ? _NameStatus.fixed : _NameStatus.editing;
    _controller.text = _product.name;
    Logger().d('${_product.isReady ? 'Edit' : 'Create'} catalog');
  }

  Widget _buildEditor() {
    return TextFormField(
      controller: _controller,
      autofocus: true,
      onFieldSubmitted: (name) => _save(),
      keyboardType: TextInputType.text,
      style: TextStyle(
        fontSize: Theme.of(context).textTheme.headline5.fontSize,
      ),
      validator: _validate,
      decoration: InputDecoration(
        hintText: Local.of(context).t('menu.product.ph.name'),
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }

  Widget _buildText() {
    return Center(
      child: Text(
        _product.name,
        style: Theme.of(context).textTheme.headline4,
      ),
    );
  }

  void _edit() {
    setState(() => _status = _NameStatus.editing);
  }

  void _save() async {
    if (!_key.currentState.validate()) {
      return;
    }

    setState(() => _status = _NameStatus.processing);

    FocusScope.of(context).unfocus();

    if (_product.isReady) {
      // edit product
      await _product.setName(_controller.text, context);
    } else if (_controller.text != _product.name) {
      // add product
      final catalog = context.read<CatalogModel>();
      _product.initial(_controller.text, catalog.length);
      await catalog.add(_product, context);
    }

    setState(() => _status = _NameStatus.fixed);
  }

  String _validate(String name) {
    final inValidText = Local.of(context).t('menu.product.error.name');
    if (name.isEmpty) return inValidText;
    // name not changed will pass
    if (_product.isReady && name == _product.name) return null;
    // invalid if menu contain repeat product
    final catalog = context.read<CatalogModel>();
    return catalog.has(name) ? inValidText : null;
  }
}

enum _NameStatus { editing, fixed, processing }
