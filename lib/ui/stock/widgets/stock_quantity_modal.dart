import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/scaffold/item_modal.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/translator.dart';

class StockQuantityModal extends StatefulWidget {
  final Quantity? quantity;

  final bool isNew;

  const StockQuantityModal({super.key, this.quantity}) : isNew = quantity == null;

  @override
  State<StockQuantityModal> createState() => _StockQuantityModalState();
}

class _StockQuantityModalState extends State<StockQuantityModal> with ItemModal<StockQuantityModal> {
  late TextEditingController _nameController;
  late TextEditingController _proportionController;
  late FocusNode _nameFocusNode;
  late FocusNode _proportionFocusNode;

  @override
  String get title => widget.isNew ? S.stockQuantityTitleCreate : S.stockQuantityTitleUpdate;

  @override
  List<Widget> buildFormFields() {
    return [
      p(TextFormField(
        key: const Key('quantity.name'),
        controller: _nameController,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: S.stockQuantityNameLabel,
          hintText: widget.quantity?.name ?? S.stockQuantityNameHint,
          filled: false,
        ),
        maxLength: 30,
        focusNode: _nameFocusNode,
        validator: Validator.textLimit(
          S.stockQuantityNameLabel,
          30,
          focusNode: _nameFocusNode,
          validator: (name) {
            return widget.quantity?.name != name && Quantities.instance.hasName(name)
                ? S.stockQuantityNameErrorRepeat
                : null;
          },
        ),
      )),
      p(TextFormField(
        key: const Key('quantity.proportion'),
        controller: _proportionController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        focusNode: _proportionFocusNode,
        onFieldSubmitted: handleFieldSubmit,
        decoration: InputDecoration(
          labelText: S.stockQuantityProportionLabel,
          helperText: S.stockQuantityProportionHelper,
          helperMaxLines: 100,
          filled: false,
        ),
        // NOTE: do we need maximum?
        validator: Validator.positiveNumber(
          S.stockQuantityProportionLabel,
          maximum: 100,
          allowNull: true,
          focusNode: _proportionFocusNode,
        ),
      )),
    ];
  }

  @override
  void initState() {
    super.initState();

    final pp = widget.quantity?.defaultProportion.toString() ?? '1';
    _nameController = TextEditingController(text: widget.quantity?.name);
    _proportionController = TextEditingController(text: pp);
    _nameFocusNode = FocusNode();
    _proportionFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _proportionController.dispose();
    _nameFocusNode.dispose();
    _proportionFocusNode.dispose();

    super.dispose();
  }

  @override
  Future<void> updateItem() async {
    final object = _parseObject();

    if (widget.isNew) {
      await Quantities.instance.addItem(Quantity(
        name: object.name!,
        defaultProportion: object.defaultProportion!,
      ));
    } else {
      await widget.quantity!.update(object);
    }

    if (mounted && context.canPop()) {
      context.pop();
    }
  }

  QuantityObject _parseObject() {
    return QuantityObject(
      name: _nameController.text,
      defaultProportion: num.tryParse(_proportionController.text) ?? 1,
    );
  }
}
