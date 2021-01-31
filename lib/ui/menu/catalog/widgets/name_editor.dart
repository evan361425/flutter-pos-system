import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:possystem/app_localizations.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/services/firestore_database.dart';
import 'package:provider/provider.dart';

class NameEditor extends StatefulWidget {
  @override
  _NameEditorState createState() => _NameEditorState();
}

class _NameEditorState extends State<NameEditor> {
  final _key = GlobalKey<FormState>();
  final _focusNode = FocusNode();
  TextEditingController _controller;
  CatalogModel _catalog;
  bool _editing;

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_editing && !_focusNode.hasFocus) {
        setState(() => _editing = false);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_controller == null) {
      _catalog = Provider.of<CatalogModel>(context);
      _editing = _catalog == null;
      var name = _editing ? '' : _catalog.name;
      _controller = TextEditingController(text: name);
      Provider.of<Logger>(context).d('${_editing ? 'Create' : 'Edit'} catalog');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      child: Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: Row(
          children: [
            Expanded(child: _editing ? _buildEditor() : _buildText()),
            IconButton(
              icon: Icon(_editing ? Icons.check : Icons.edit),
              iconSize: Theme.of(context).textTheme.headline4.fontSize,
              onPressed: _editing ? _save : _edit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: true,
      onFieldSubmitted: (name) => _save(),
      keyboardType: TextInputType.text,
      style:
          TextStyle(fontSize: Theme.of(context).textTheme.headline4.fontSize),
      validator: (value) =>
          value.isEmpty ? Trans.of(context).t('menu.catalog.error.name') : null,
      decoration: InputDecoration(
        hintText: Trans.of(context).t('menu.catalog.ph.name'),
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
    setState(() => _editing = true);
  }

  void _save() async {
    if (!_key.currentState.validate()) {
      return;
    }
    _focusNode.unfocus();

    if (_controller.text != _catalog.name) {
      var firestore = Provider.of<FirestoreDatabase>(context, listen: false);
      await _catalog.setName(_controller.text, firestore);
    }

    setState(() => _editing = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
