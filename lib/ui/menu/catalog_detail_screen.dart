import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:possystem/app_localizations.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/services/firestore_database.dart';
import 'package:provider/provider.dart';

class CatalogDetailScreen extends StatefulWidget {
  @override
  _CatalogDetailScreenState createState() => _CatalogDetailScreenState();
}

class _CatalogDetailScreenState extends State<CatalogDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController;
  CatalogModel _catalog;
  bool _editingName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final CatalogModel _catalogModel =
        ModalRoute.of(context).settings.arguments;
    if (_catalogModel != null) {
      _catalog = _catalogModel;
    }

    _editingName = _catalog == null;
    _nameController =
        TextEditingController(text: _catalog == null ? '' : _catalog.name);
    Provider.of<Logger>(context).d(_editingName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _catalog == null
              ? Trans.of(context).t('menu.catalog.title.edit')
              : Trans.of(context).translate('menu.catalog.title.add'),
        ),
      ),
      body: _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
                child: _editingName ? _buildNameEditor() : _buildNameText()),
            IconButton(
              icon: Icon(_editingName ? Icons.check : Icons.edit),
              iconSize: Theme.of(context).textTheme.headline4.fontSize,
              onPressed: _editingName
                  ? _saveName
                  : () => setState(() => _editingName = true),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNameEditor() {
    return TextFormField(
      controller: _nameController,
      style: Theme.of(context).textTheme.headline4,
      validator: (value) =>
          value.isEmpty ? Trans.of(context).t('menu.catalog.error.name') : null,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).iconTheme.color, width: 2),
        ),
        labelText: Trans.of(context).t('menu.catalog.ph.name'),
      ),
    );
  }

  Widget _buildNameText() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(0.5),
      ),
      child: Text(
        _catalog.name,
        style: Theme.of(context).textTheme.headline4,
      ),
    );
  }

  void _saveName() {
    if (!_formKey.currentState.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (_nameController.text == _catalog.name) {
      return;
    }

    var firestore = Provider.of<FirestoreDatabase>(context, listen: false);
    _catalog.setName(_nameController.text. firestore);
  }
}
