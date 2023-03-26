import 'package:flutter/material.dart';
import 'package:possystem/components/style/image_holder.dart';
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
  State<CatalogModal> createState() => _CatalogModalState();
}

class _CatalogModalState extends State<CatalogModal>
    with ItemModal<CatalogModal> {
  late TextEditingController _nameController;
  late FocusNode _nameFocusNode;

  String? _image;

  @override
  List<Widget> buildFormFields() {
    return [
      EditImageHolder(
        path: _image,
        onSelected: (image) => setState(() => _image = image),
      ),
      TextFormField(
        key: const Key('catalog.name'),
        controller: _nameController,
        focusNode: _nameFocusNode,
        textInputAction: TextInputAction.send,
        textCapitalization: TextCapitalization.words,
        autofocus: widget.isNew,
        decoration: InputDecoration(
          labelText: S.menuCatalogNameLabel,
          hintText: S.menuCatalogNameHint,
          filled: false,
        ),
        onFieldSubmitted: (_) => handleSubmit(),
        maxLength: 30,
        validator: Validator.textLimit(
          S.menuCatalogNameLabel,
          30,
          focusNode: _nameFocusNode,
          validator: (name) {
            return widget.catalog?.name != name && Menu.instance.hasName(name)
                ? S.menuCatalogNameRepeatError
                : null;
          },
        ),
      ),
    ];
  }

  Future<Catalog> getCatalog() async {
    final object = CatalogObject(name: _nameController.text, imagePath: _image);
    final catalog = widget.catalog ??
        Catalog(
          name: object.name,
          index: Menu.instance.newIndex,
          imagePath: _image,
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
    _image = widget.catalog?.imagePath;
    _nameFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Future<void> updateItem() async {
    final catalog = await getCatalog();

    if (mounted) {
      // go to catalog screen
      widget.isNew
          ? Navigator.of(context).popAndPushNamed(
              Routes.menuCatalog,
              arguments: catalog,
            )
          : Navigator.of(context).pop();
    }
  }
}
