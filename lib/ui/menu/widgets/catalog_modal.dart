import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/scaffold/item_modal.dart';
import 'package:possystem/components/style/image_holder.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/translator.dart';

class CatalogModal extends StatefulWidget {
  final Catalog? catalog;

  final bool isNew;

  const CatalogModal({super.key, this.catalog}) : isNew = catalog == null;

  @override
  State<CatalogModal> createState() => _CatalogModalState();
}

class _CatalogModalState extends State<CatalogModal> with ItemModal<CatalogModal> {
  late TextEditingController _nameController;
  late FocusNode _nameFocusNode;

  String? _image;

  @override
  String get title => widget.isNew ? S.menuCatalogTitleCreate : S.menuCatalogTitleUpdate;

  @override
  List<Widget> buildFormFields() {
    return [
      EditImageHolder(
        path: _image,
        onSelected: (image) => setState(() => _image = image),
      ),
      p(TextFormField(
        key: const Key('catalog.name'),
        controller: _nameController,
        focusNode: _nameFocusNode,
        textInputAction: TextInputAction.send,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: S.menuCatalogNameLabel,
          hintText: widget.catalog?.name ?? S.menuCatalogNameHint,
          filled: false,
        ),
        onFieldSubmitted: handleFieldSubmit,
        maxLength: 30,
        validator: Validator.textLimit(
          S.menuCatalogNameLabel,
          30,
          focusNode: _nameFocusNode,
          validator: (name) {
            return widget.catalog?.name != name && Menu.instance.hasName(name) ? S.menuCatalogNameErrorRepeat : null;
          },
        ),
      )),
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
      widget.isNew ? context.pop(catalog) : context.pop();
    }
  }
}
