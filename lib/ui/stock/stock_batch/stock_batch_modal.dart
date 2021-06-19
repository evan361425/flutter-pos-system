import 'package:flutter/material.dart';
import 'package:possystem/components/custom_styles.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/constants/constant.dart';
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

class _StockBatchModalState extends State<StockBatchModal>
    with ItemModal<StockBatchModal> {
  final updateData = <String, num>{};
  final List<IngredientModel> ingredients = StockModel.instance.itemList;

  final TextEditingController _nameController = TextEditingController();

  @override
  Widget body() {
    final textTheme = Theme.of(context).textTheme;
    final fields = <Widget>[
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
            itemBuilder: (_, index) => _fieldIngredient(ingredients[index]),
            itemCount: StockModel.instance.length,
          ),
        ),
      ),
    ];

    return form(fields);
  }

  @override
  void initState() {
    super.initState();

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

  StockBatchObject _parseObject() {
    updateData.clear();
    formKey.currentState!.save();

    return StockBatchObject(name: _nameController.text, data: updateData);
  }

  @override
  Future<void> updateItem() async {
    final object = _parseObject();

    if (widget.batch != null) {
      await widget.batch!.update(object);
    } else {
      final model = StockBatchModel(name: object.name, data: object.data);

      await StockBatchRepo.instance.setItem(model);
    }

    Navigator.of(context).pop();
  }

  @override
  String? validate() {
    final name = _nameController.text;

    if (widget.batch?.name != name && StockBatchRepo.instance.hasBatch(name)) {
      return '批量名稱重複';
    }
  }
}
