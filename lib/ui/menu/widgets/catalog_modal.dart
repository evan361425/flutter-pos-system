import 'package:flutter/material.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class CatalogModal extends StatefulWidget {
  final Catalog? catalog;

  final bool isNew;

  const CatalogModal({Key? key, this.catalog})
      : isNew = catalog == null,
        super(key: key);

  @override
  _CatalogModalState createState() => _CatalogModalState();
}

class _CatalogModalState extends State<CatalogModal>
    with ItemModal<CatalogModal> {
  late TextEditingController _nameController;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  List<Widget> formFields() {
    return [
      TextFormField(
        key: Key('catalog.name'),
        controller: _nameController,
        textInputAction: TextInputAction.send,
        textCapitalization: TextCapitalization.words,
        autofocus: widget.isNew,
        decoration: InputDecoration(
          labelText: tt('menu.catalog.label.name'),
          hintText: tt('menu.catalog.hint.name'),
          errorText: errorMessage,
          filled: false,
        ),
        onFieldSubmitted: (_) => handleSubmit(),
        maxLength: 30,
        validator: Validator.textLimit(tt('menu.catalog.label.name'), 30),
      )
    ];
  }

  Future<Catalog> getCatalog() async {
    final object = CatalogObject(name: _nameController.text);
    final catalog = widget.catalog ??
        Catalog(
          name: object.name,
          index: Menu.instance.newIndex,
        );

    if (widget.isNew) {
      await Menu.instance.addItem(catalog);
    } else {
      await catalog.update(object);
    }

    return catalog;
  }

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.catalog?.name);
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

    if (widget.catalog?.name != name && Menu.instance.hasName(name)) {
      return tt('menu.catalog.error.name');
    }
  }
}
