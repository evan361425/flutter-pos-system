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

  const QuantityModal({Key? key, this.quantity})
      : isNew = quantity == null,
        super(key: key);

  @override
  _QuantityModalState createState() => _QuantityModalState();
}

class _QuantityModalState extends State<QuantityModal>
    with ItemModal<QuantityModal> {
  TextEditingController? _nameController;
  TextEditingController? _proportionController;

  @override
  void dispose() {
    _nameController?.dispose();
    _proportionController?.dispose();

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
          labelText: tt('stock.quantity.label.name'),
          hintText: tt('stock.quantity.hint.name'),
          errorText: errorMessage,
          filled: false,
        ),
        style: Theme.of(context).textTheme.headline6,
        autofocus: widget.isNew,
        maxLength: 30,
        validator: Validator.textLimit(tt('stock.quantity.label.name'), 30),
      ),
      TextFormField(
        key: const Key('quantity.proportion'),
        controller: _proportionController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => handleSubmit(),
        decoration: InputDecoration(
          labelText: tt('stock.quantity.label.proportion'),
          errorText: errorMessage,
          helperText: tt('stock.quantity.helper.proportion'),
          helperMaxLines: 100,
          filled: false,
        ),
        // NOTE: do we need maximum?
        validator: Validator.positiveNumber(
            tt('stock.quantity.label.proportion'),
            maximum: 100),
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
    final name = _nameController!.text;

    if (widget.quantity?.name != name && Quantities.instance.hasName(name)) {
      return tt('stock.quantity.error.name');
    }
  }

  QuantityObject _parseObject() {
    return QuantityObject(
      name: _nameController!.text,
      defaultProportion: num.parse(_proportionController!.text),
    );
  }
}
