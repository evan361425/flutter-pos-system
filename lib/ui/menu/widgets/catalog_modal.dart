import 'package:flutter/material.dart';
import 'package:possystem/components/mixin/item_modal.dart';
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

class _CatalogModalState extends State<CatalogModal>
    with ItemModal<CatalogModal> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (!widget.isNew) {
      _nameController.text = widget.catalog!.name;
    }
  }

  @override
  List<Widget> formFields() {
    return [
      TextFormField(
        controller: _nameController,
        textInputAction: TextInputAction.send,
        textCapitalization: TextCapitalization.words,
        autofocus: true,
        decoration: InputDecoration(
          labelText: '種類名稱，漢堡',
          errorText: errorMessage,
          filled: false,
        ),
        onFieldSubmitted: (_) => handleSubmit(),
        maxLength: 30,
        validator: Validator.textLimit('種類名稱', 30),
      )
    ];
  }

  Future<CatalogModel> getCatalog() async {
    final object = CatalogObject(name: _nameController.text);

    if (widget.isNew) {
      final catalog = CatalogModel(
        name: object.name,
        index: MenuModel.instance.newIndex,
      );

      await MenuModel.instance.setItem(catalog);
      return catalog;
    } else {
      await widget.catalog!.update(object);
      return widget.catalog!;
    }
  }

  @override
  Future<void> updateItem() async {
    final catalog = await getCatalog();

    // go to catalog screen
    widget.isNew
        ? Navigator.of(context).popAndPushNamed(
            Routes.menuCatalog,
            arguments: catalog,
          )
        : Navigator.of(context).pop();
  }

  @override
  String? validate() {
    final name = _nameController.text;

    if (widget.catalog?.name != name && MenuModel.instance.hasCatalog(name)) {
      return '種類名稱重複';
    }
  }
}
