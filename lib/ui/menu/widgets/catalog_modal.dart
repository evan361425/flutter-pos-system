import 'package:flutter/material.dart';
import 'package:possystem/components/circular_loading.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/routes.dart';

class CatalogModal extends StatefulWidget {
  CatalogModal({Key key, this.catalog})
      : isNew = catalog == null,
        super(key: key);

  final CatalogModel catalog;
  final bool isNew;

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
        padding: const EdgeInsets.all(kSpacing3),
        child: Center(
          child: Form(
            key: _formKey,
            child: _nameField(),
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    if (isSaving || !_formKey.currentState.validate()) return;

    final name = _controller.text;

    if (widget.catalog?.name != name && MenuModel.instance.hasCatalog(name)) {
      return setState(() => errorMessage = '種類名稱重複');
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    final catalog = _updateCatalog();

    widget.isNew
        ? Navigator.of(context).popAndPushNamed(
            Routes.menuCatalog,
            arguments: catalog,
          )
        : Navigator.of(context).pop();
  }

  CatalogModel _updateCatalog() {
    final object = CatalogObject(
      name: _controller.text,
    );

    if (widget.isNew) {
      final catalog = CatalogModel(
        name: object.name,
        index: MenuModel.instance.newIndex,
      );

      MenuModel.instance.updateCatalog(catalog);
      return catalog;
    } else {
      widget.catalog.update(object);
      return widget.catalog;
    }
  }

  Widget _trailingAction() {
    return isSaving
        ? CircularLoading()
        : TextButton(
            onPressed: () => _onSubmit(),
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
      onFieldSubmitted: (_) => _onSubmit(),
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
