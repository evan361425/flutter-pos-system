import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/routes.dart';

class CatalogModal extends StatefulWidget {
  final CatalogModel? catalog;

  final bool isNew;
  CatalogModal({Key? key, this.catalog})
      : isNew = catalog == null,
        super(key: key);

  @override
  _CatalogModalState createState() => _CatalogModalState();
}

class _CatalogModalState extends State<CatalogModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

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
      body: Padding(
        padding: const EdgeInsets.all(kSpacing3),
        child: Center(
          child: Form(
            key: _formKey,
            child: _fieldName(),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _nameController.text = widget.catalog?.name ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Widget _fieldName() {
    return TextFormField(
      controller: _nameController,
      textInputAction: TextInputAction.send,
      textCapitalization: TextCapitalization.words,
      autofocus: true,
      decoration: InputDecoration(
        labelText: '種類名稱，漢堡',
        errorText: errorMessage,
        filled: false,
      ),
      onFieldSubmitted: (_) => _handleSubmit(),
      maxLength: 30,
      validator: Validator.textLimit('種類名稱', 30),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_validate()) return;

    final catalog = await _updateCatalog();

    // go to catalog screen
    widget.isNew
        ? Navigator.of(context).popAndPushNamed(
            Routes.menuCatalog,
            arguments: catalog,
          )
        : Navigator.of(context).pop();
  }

  CatalogObject _parseObject() {
    return CatalogObject(
      name: _nameController.text,
    );
  }

  Future<CatalogModel> _updateCatalog() async {
    final object = _parseObject();

    if (widget.isNew) {
      final catalog = CatalogModel(
        name: object.name,
        index: MenuModel.instance.newIndex,
      );

      await MenuModel.instance.setChild(catalog);
      return catalog;
    } else {
      await widget.catalog!.update(object);
      return widget.catalog!;
    }
  }

  bool _validate() {
    if (isSaving || !_formKey.currentState!.validate()) return false;

    final name = _nameController.text;

    if (widget.catalog?.name != name && MenuModel.instance.hasCatalog(name)) {
      setState(() => errorMessage = '種類名稱重複');
      return false;
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    return true;
  }
}
