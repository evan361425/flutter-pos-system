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
  _QuantityModalState createState() => _QuantityModalState();
}

class _QuantityModalState extends State<QuantityModal>
    with ItemModal<QuantityModal> {
  late TextEditingController _nameController;
  late TextEditingController _proportionController;

  @override
  void dispose() {
    _nameController.dispose();
    _proportionController.dispose();

    super.dispose();
  }

  @override
  List<Widget> formFields() {
    return [
      TextFormField(
        key: const Key('quantity.name'),
        controller: _nameController,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: S.quantityNameLabel,
          hintText: S.quantityNameHint,
          errorText: errorMessage,
          filled: false,
        ),
        autofocus: widget.isNew,
        maxLength: 30,
        validator: Validator.textLimit(S.quantityNameLabel, 30),
      ),
      TextFormField(
        key: const Key('quantity.proportion'),
        controller: _proportionController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => handleSubmit(),
        decoration: InputDecoration(
          labelText: S.quantityProportionLabel,
          errorText: errorMessage,
          helperText: S.quantityProportionHelper,
          helperMaxLines: 100,
          filled: false,
        ),
        // NOTE: do we need maximum?
        validator: Validator.positiveNumber(
          S.quantityProportionLabel,
          maximum: 100,
          allowNull: true,
        ),
      )
    ];
  }

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.quantity?.name);

    final pp = widget.quantity?.defaultProportion.toString() ?? '1';
    _proportionController = TextEditingController(text: pp);
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

    Navigator.of(context).pop();
  }

  @override
  String? validate() {
    final name = _nameController.text;

    if (widget.quantity?.name != name && Quantities.instance.hasName(name)) {
      return S.quantityNameRepeatError;
    }

    return null;
  }

  QuantityObject _parseObject() {
    return QuantityObject(
      name: _nameController.text,
      defaultProportion: num.tryParse(_proportionController.text),
    );
  }
}
