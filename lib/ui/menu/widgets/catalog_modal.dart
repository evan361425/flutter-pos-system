import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/routes.dart';
import 'package:provider/provider.dart';

class CatalogModal extends StatefulWidget {
  CatalogModal({Key key, this.catalog}) : super(key: key);

  final CatalogModel catalog;

  bool get isNew => catalog == null;

  @override
  _CatalogModalState createState() => _CatalogModalState();
}

class _CatalogModalState extends State<CatalogModal> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  bool isSaving = false;
  String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
        actions: [_trailingAction()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: Center(
          child: Form(
            key: _formKey,
            child: _nameField(),
          ),
        ),
      ),
    );
  }

  void _onSubmit(String name) {
    if (isSaving || !_formKey.currentState.validate()) return;

    final menu = context.read<MenuModel>();

    if (widget.catalog?.name != name && menu.hasCatalog(name)) {
      return setState(() => errorMessage = '種類名稱重複');
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    final catalog = _updateCatalog(name, menu);

    widget.isNew
        ? Navigator.of(context)
            .popAndPushNamed(Routes.catalog, arguments: catalog)
        : Navigator.of(context).pop();
  }

  CatalogModel _updateCatalog(String name, MenuModel menu) {
    widget.catalog?.update(name: name);

    final catalog =
        widget.catalog ?? CatalogModel(name: name, index: menu.newIndex);

    menu.updateCatalog(catalog);
    return catalog;
  }

  Widget _trailingAction() {
    return isSaving
        ? CircularProgressIndicator()
        : TextButton(
            onPressed: () => _onSubmit(_controller.text),
            child: Text('儲存'),
          );
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
    _controller.text = widget.catalog?.name;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
