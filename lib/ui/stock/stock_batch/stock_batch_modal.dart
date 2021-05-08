import 'package:flutter/material.dart';
import 'package:possystem/components/scaffold/fade_in_title.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/stock_batch_repo.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/models/stock/stock_batch_model.dart';

class StockBatchModal extends StatefulWidget {
  const StockBatchModal({Key key, this.batch}) : super(key: key);

  final StockBatchModel batch;

  @override
  _StockBatchModalState createState() => _StockBatchModalState();
}

class _StockBatchModalState extends State<StockBatchModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final updateData = <String, num>{};

  bool isSaving = false;
  String errorMessage;

  void _onSubmit() {
    if (isSaving || !_formKey.currentState.validate()) return;

    final name = _nameController.text;

    if (widget.batch?.name != name &&
        StockBatchRepo.instance.hasContain(name)) {
      return setState(() => errorMessage = '批量名稱重複');
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    _updateBatches(name);
    Navigator.of(context).pop();
  }

  void _updateBatches(String name) {
    updateData.clear();
    _formKey.currentState.save();

    if (widget.batch != null) {
      widget.batch.update(StockBatchObject(name: name, data: updateData));
    }

    StockBatchRepo.instance.updateBatch(
      widget.batch ?? StockBatchModel(name: name, data: updateData),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeInTitleScaffold(
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(KIcons.back),
      ),
      trailing: _trailingAction(),
      title: widget.batch?.name ?? '',
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(kPadding),
              child: _nameField(),
            ),
            for (var ingredient in StockModel.instance.ingredients.values)
              _ingredientField(ingredient),
          ],
        ),
      ),
    );
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
        labelText: '批量名稱，Costco 採購',
        errorText: errorMessage,
        filled: false,
      ),
      style: Theme.of(context).textTheme.headline6,
      autofocus: widget.batch == null,
      maxLength: 30,
      validator: Validator.textLimit('批量名稱', 30),
    );
  }

  Widget _ingredientField(IngredientModel ingredient) {
    final nonSet = widget.batch == null || widget.batch.hasNot(ingredient.id);

    return TextFormField(
      onSaved: (String value) {
        final numValue = num.tryParse(value);
        if (numValue != null && numValue != 0) {
          updateData[ingredient.id] = numValue;
        }
      },
      initialValue: nonSet ? '' : widget.batch[ingredient.id].toString(),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: ingredient.name,
        hintText: '設定增加／減少的量',
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _nameController.text = widget.batch?.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
