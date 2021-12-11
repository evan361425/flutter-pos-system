import 'package:flutter/material.dart';
import 'package:possystem/components/style/image_holder.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/image_file.dart';
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

  late ImageFile _image;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  List<Widget> formFields() {
    return [
      TextFormField(
        key: const Key('catalog.name'),
        controller: _nameController,
        textInputAction: TextInputAction.send,
        textCapitalization: TextCapitalization.words,
        autofocus: widget.isNew,
        decoration: InputDecoration(
          labelText: S.menuCatalogNameLabel,
          hintText: S.menuCatalogNameHint,
          errorText: errorMessage,
          filled: false,
        ),
        onFieldSubmitted: (_) => handleSubmit(),
        maxLength: 30,
        validator: Validator.textLimit(S.menuCatalogNameLabel, 30),
      ),
      ImageHolder(
        path: _image.path,
        onSelected: (image) => setState(() => _image = image),
      ),
    ];
  }

  Future<Catalog> createCatalog() async {
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
    _image = ImageFile(path: widget.catalog?.imagePath);
  }

  @override
  Future<void> updateItem() async {
    final catalog = await createCatalog();
    await catalog.replaceImage(_image);

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
      return S.menuCatalogNameRepeatError;
    }
  }
}
