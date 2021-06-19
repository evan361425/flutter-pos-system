import 'package:flutter/material.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/quantity_repo.dart';
import 'package:possystem/models/stock/quantity_model.dart';

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
          labelText: '份量名稱，多量',
          errorText: errorMessage,
          filled: false,
        ),
        style: Theme.of(context).textTheme.headline6,
        autofocus: widget.quantity == null,
        maxLength: 30,
        validator: Validator.textLimit('份量名稱', 30),
      ),
      TextFormField(
        controller: _proportionController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => handleSubmit(),
        decoration: InputDecoration(
          labelText: '預設比例',
          errorText: errorMessage,
          helperText:
              '當產品成份使用此份量時，預設替該成份增加的比例。\n例如：此份量為「多量」預設份量為「1.5」，\n今有一產品「起司漢堡」的成份「起司」，且每份漢堡會使用「2」單位的起司，\n當增加此份量時，則會自動替「起司」設定為「3」（1.5 * 2）的份量。\n若設為「1」則無任何影響。',
          helperMaxLines: 100,
          filled: false,
        ),
        // NOTE: do we need maximum?
        validator: Validator.positiveNumber('庫存', maximum: 10),
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

    if (widget.quantity?.name != name && QuantityRepo.instance.hasItem(name)) {
      return '份量名稱重複';
    }
  }

  QuantityObject _parseObject() {
    return QuantityObject(
      name: _nameController.text,
      defaultProportion: num.parse(_proportionController.text),
    );
  }
}
