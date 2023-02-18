import 'package:flutter/material.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/translator.dart';

class QuantityModal extends StatefulWidget {
  final Quantity? quantity;

  final bool isNew;

  const QuantityModal(this.quantity, {Key? key})
      : isNew = quantity == null,
        super(key: key);

  @override
  State<QuantityModal> createState() => _QuantityModalState();
}

class _QuantityModalState extends State<QuantityModal>
    with ItemModal<QuantityModal> {
  late TextEditingController _nameController;
  late TextEditingController _proportionController;
  late FocusNode _nameFocusNode;
  late FocusNode _proportionFocusNode;

  @override
  List<Widget> buildFormFields() {
    return [
      TextFormField(
        key: const Key('quantity.name'),
        controller: _nameController,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: S.quantityNameLabel,
          hintText: S.quantityNameHint,
          filled: false,
        ),
        autofocus: widget.isNew,
        maxLength: 30,
        focusNode: _nameFocusNode,
        validator: Validator.textLimit(
          S.quantityNameLabel,
          30,
          focusNode: _nameFocusNode,
          validator: (name) {
            return widget.quantity?.name != name &&
                    Quantities.instance.hasName(name)
                ? S.quantityNameRepeatError
                : null;
          },
        ),
      ),
      TextFormField(
        key: const Key('quantity.proportion'),
        controller: _proportionController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        focusNode: _proportionFocusNode,
        onFieldSubmitted: (_) => handleSubmit(),
        decoration: InputDecoration(
          labelText: S.quantityProportionLabel,
          helperText: S.quantityProportionHelper,
          helperMaxLines: 100,
          filled: false,
        ),
        // NOTE: do we need maximum?
        validator: Validator.positiveNumber(
          S.quantityProportionLabel,
          maximum: 100,
          allowNull: true,
          focusNode: _proportionFocusNode,
        ),
      )
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

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  QuantityObject _parseObject() {
    return QuantityObject(
      name: _nameController.text,
      defaultProportion: num.tryParse(_proportionController.text) ?? 1,
    );
  }
}
