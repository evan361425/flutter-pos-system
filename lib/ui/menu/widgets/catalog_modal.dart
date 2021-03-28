import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/models/menu_model.dart';
import 'package:possystem/routes.dart';
import 'package:provider/provider.dart';

class CatalogModal extends StatefulWidget {
  CatalogModal({Key key, this.catalog}) : super(key: key);

  final CatalogModel catalog;

  @override
  _CatalogModalState createState() => _CatalogModalState();
}

class _CatalogModalState extends State<CatalogModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  bool isSaving = false;
  String errorMessage;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(Icons.arrow_back_ios_sharp),
        ),
        trailing: isSaving
            ? CircularProgressIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _onSubmit(_controller.text),
                child: Text('儲存'),
              ),
      ),
      child: Material(
        child: Padding(
          padding: const EdgeInsets.all(kPadding),
          child: Center(
            child: Form(
              key: _formKey,
              child: _nameField(),
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmit(String name) {
    if (isSaving || !_formKey.currentState.validate()) return;

    final menu = context.read<MenuModel>();

    if (widget.catalog.name != name && menu.hasCatalog(name)) {
      return setState(() => errorMessage = '種類名稱重複');
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    if (widget.catalog.isReady) {
      widget.catalog.update(name: name);
      menu.catalogChanged();
      Navigator.of(context).pop();
    } else {
      final catalog = menu.buildCatalog(name: name);
      Navigator.of(context).popAndPushNamed(Routes.catalog, arguments: catalog);
    }
  }

  Widget _nameField() {
    return TextFormField(
      controller: _controller,
      textInputAction: TextInputAction.send,
      textCapitalization: TextCapitalization.words,
      autofocus: true,
      decoration: InputDecoration(
        labelText: '種類名稱，漢堡',
        errorText: errorMessage,
        filled: false,
      ),
      onFieldSubmitted: _onSubmit,
      maxLength: 30,
      validator: Validator.textLimit('種類名稱', 30),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.text = widget.catalog.name;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
