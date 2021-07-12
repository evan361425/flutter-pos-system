import 'package:flutter/material.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/quantity_repo.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/translator.dart';

class QuantityModal extends StatefulWidget {
  final QuantityModel? quantity;

  const QuantityModal({Key? key, this.quantity}) : super(key: key);

  @override
  _QuantityModalState createState() => _QuantityModalState();
}

class _QuantityModalState extends State<QuantityModal>
    with ItemModal<QuantityModal> {
  final _nameController = TextEditingController();
  final _proportionController = TextEditingController();

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
        autofocus: widget.quantity == null,
        maxLength: 30,
        validator: Validator.textLimit(tt('stock.quantity.label.name'), 30),
      ),
      TextFormField(
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

    _nameController.text = widget.quantity?.name ?? '';
    _proportionController.text =
        widget.quantity?.defaultProportion.toString() ?? '1';
  }

  @override
  Future<void> updateItem() async {
    final object = _parseObject();

    if (widget.quantity != null) {
      await widget.quantity!.update(object);
    }

    // quantity is not notifier, need set item to fire listener
    await QuantityRepo.instance.setItem(widget.quantity ??
        QuantityModel(
          name: object.name!,
          defaultProportion: object.defaultProportion!,
        ));

    Navigator.of(context).pop();
  }

  @override
  String? validate() {
    final name = _nameController.text;

    if (widget.quantity?.name != name && QuantityRepo.instance.hasName(name)) {
      return tt('stock.quantity.error.name');
    }
  }

  QuantityObject _parseObject() {
    return QuantityObject(
      name: _nameController.text,
      defaultProportion: num.parse(_proportionController.text),
    );
  }
}
