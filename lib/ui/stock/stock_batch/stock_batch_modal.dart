import 'package:flutter/material.dart';
import 'package:possystem/components/custom_styles.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/stock_batch_repo.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/models/stock/stock_batch_model.dart';

class StockBatchModal extends StatefulWidget {
  final StockBatchModel? batch;

  const StockBatchModal({Key? key, this.batch}) : super(key: key);

  @override
  _StockBatchModalState createState() => _StockBatchModalState();
}

class _StockBatchModalState extends State<StockBatchModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final updateData = <String, num>{};
  final List<IngredientModel> ingredients = StockModel.instance.itemList;

  bool isSaving = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
        actions: [
          TextButton(
            onPressed: () => _handleSubmit(),
            child: Text('儲存'),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(kSpacing3),
              child: _fieldName(textTheme),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: kSpacing1),
              child: Text('點選以設定不同成分欲設定的量', style: textTheme.muted),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: kSpacing3),
                child: ListView.builder(
                  itemBuilder: (_, index) =>
                      _fieldIngredient(ingredients[index]),
                  itemCount: StockModel.instance.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _nameController.text = widget.batch?.name ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Widget _fieldIngredient(IngredientModel ingredient) {
    return TextFormField(
      onSaved: (String? value) {
        final numValue = num.tryParse(value!);
        if (numValue != null && numValue != 0) {
          updateData[ingredient.id] = numValue;
        }
      },
      initialValue: widget.batch?.getNumOfId(ingredient.id)?.toString() ?? '',
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: ingredient.name,
        hintText: '設定增加／減少的量',
      ),
    );
  }

  Widget _fieldName(TextTheme textTheme) {
    return TextFormField(
      controller: _nameController,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: '批量名稱，Costco 採購',
        errorText: errorMessage,
        filled: false,
      ),
      style: textTheme.headline6,
      autofocus: widget.batch == null,
      maxLength: 30,
      validator: Validator.textLimit('批量名稱', 30),
    );
  }

  void _handleSubmit() {
    if (!_validate()) return;

    _updateBatches();

    Navigator.of(context).pop();
  }

  void _updateBatches() {
    updateData.clear();
    _formKey.currentState!.save();

    final name = _nameController.text;

    if (widget.batch != null) {
      widget.batch!.update(StockBatchObject(name: name, data: updateData));
    } else {
      final model = StockBatchModel(name: name, data: updateData);

      StockBatchRepo.instance.setItem(model);
    }
  }

  bool _validate() {
    if (isSaving || !_formKey.currentState!.validate()) return false;

    final name = _nameController.text;

    if (widget.batch?.name != name && StockBatchRepo.instance.hasBatch(name)) {
      setState(() => errorMessage = '批量名稱重複');
      return false;
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });
    return true;
  }
}
