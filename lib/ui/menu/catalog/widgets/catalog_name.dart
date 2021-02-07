import 'package:flutter/material.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/models/menu_model.dart';
import 'package:provider/provider.dart';

class CatalogName extends StatefulWidget {
  @override
  _CatalogNameState createState() => _CatalogNameState();
}

class _CatalogNameState extends State<CatalogName> {
  final _key = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  CatalogModel _catalog;
  _NameStatus _status;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      child: Row(
        children: [
          Expanded(
            child: _status == _NameStatus.fixed ? _buildText() : _buildEditor(),
          ),
          _status == _NameStatus.processing
              ? CircularProgressIndicator()
              : _status == _NameStatus.editing
                  ? IconButton(icon: Icon(Icons.check), onPressed: _save)
                  : IconButton(icon: Icon(Icons.edit), onPressed: _edit),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _catalog = context.read<CatalogModel>();
    _status = _catalog.isReady ? _NameStatus.fixed : _NameStatus.editing;
    _controller.text = _catalog.name;
  }

  Widget _buildEditor() {
    return TextFormField(
      controller: _controller,
      autofocus: true,
      onFieldSubmitted: (name) => _save(),
      maxLength: 30,
      keyboardType: TextInputType.text,
      style: TextStyle(
        fontSize: Theme.of(context).textTheme.headline5.fontSize,
      ),
      validator: _validate,
      decoration: InputDecoration(
        hintText: Local.of(context).t('menu.catalog.ph.name'),
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }

  Widget _buildText() {
    return Center(
      child: Text(
        _catalog.name,
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

    if (_catalog.isReady) {
      // edit catalog
      await _catalog.setName(_controller.text, context);
    } else if (_controller.text != _catalog.name) {
      // add catalog
      final menu = context.read<MenuModel>();
      _catalog.initial(_controller.text, menu.length);
      await menu.add(_catalog, context);
    }

    setState(() => _status = _NameStatus.fixed);
  }

  String _validate(String name) {
    final inValidText = Local.of(context).t('menu.catalog.error.name');
    if (name.isEmpty) return inValidText;
    // name not changed will pass
    if (_catalog.isReady && name == _catalog.name) return null;
    // invalid if menu contain repeat catalog
    final menu = context.read<MenuModel>();
    return menu.has(name) ? inValidText : null;
  }
}

enum _NameStatus { editing, fixed, processing }
