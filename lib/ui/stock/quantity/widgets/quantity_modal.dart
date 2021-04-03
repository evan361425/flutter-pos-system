import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/repository/quantity_index_model.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:provider/provider.dart';

class QuantityModal extends StatefulWidget {
  const QuantityModal({Key key, this.quantity}) : super(key: key);

  final QuantityModel quantity;

  @override
  _QuantityModalState createState() => _QuantityModalState();
}

class _QuantityModalState extends State<QuantityModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _proportionController = TextEditingController();

  bool isSaving = false;
  String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
        actions: [_trailingAction()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _nameField(),
              _proportionField(),
            ],
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    if (isSaving || !_formKey.currentState.validate()) return;

    final name = _nameController.text;
    final quantities = context.read<QuantityIndexModel>();

    if (widget.quantity?.name != name && quantities.hasContain(name)) {
      return setState(() => errorMessage = '份量名稱重複');
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    _updateQuantity(name, quantities);
    Navigator.of(context).pop();
  }

  void _updateQuantity(String name, QuantityIndexModel quantities) {
    final proportion = double.parse(_proportionController.text);

    if (widget.quantity != null) {
      widget.quantity.update(name: name, proportion: proportion);
    } else {
      quantities.addQuantity(
        QuantityModel(name: name, defaultProportion: proportion),
      );
    }

    quantities.changedQuantity();
  }

  Widget _trailingAction() {
    return isSaving
        ? CircularProgressIndicator()
        : TextButton(
            onPressed: () => _onSubmit(),
            child: Text('儲存'),
          );
  }

  Widget _nameField() {
    return TextFormField(
      controller: _nameController,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: '份量名稱，多量',
        errorText: errorMessage,
        filled: false,
      ),
      style: Theme.of(context).textTheme.headline6,
      autofocus: widget.quantity == null,
      maxLength: 30,
      validator: Validator.textLimit('份量名稱', 30),
    );
  }

  Widget _proportionField() {
    return TextFormField(
      controller: _proportionController,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '預設比例',
        errorText: errorMessage,
        helperText:
            '當產品成份使用此份量時，預設替該成份增加的比例。\n例如：此份量為「多量」預設份量為「1.5」，\n今有一產品「起司漢堡」的成份「起司」，且每份漢堡會使用「2」單位的起司，\n當增加此份量時，則會自動替「起司」設定為「3」（1.5 * 2）的份量。\n若設為「1」則無任何影響。',
        helperMaxLines: 100,
        filled: false,
      ),
      // NOTE: do we need maximum?
      validator: Validator.positiveDouble('庫存', maximum: 10),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _nameController.text = widget.quantity?.name;
    _proportionController.text =
        widget.quantity?.defaultProportion?.toString() ?? '1';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _proportionController.dispose();
    super.dispose();
  }
}
