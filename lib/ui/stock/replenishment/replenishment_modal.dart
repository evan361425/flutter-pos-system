import 'package:flutter/material.dart';
import 'package:possystem/components/style/custom_styles.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/replenishment.dart';
import 'package:possystem/translator.dart';

class ReplenishmentModal extends StatefulWidget {
  final Replenishment? replenishment;

  final bool isNew;

  const ReplenishmentModal({Key? key, this.replenishment})
      : isNew = replenishment == null,
        super(key: key);

  @override
  _ReplenishmentModalState createState() => _ReplenishmentModalState();
}

class _ReplenishmentModalState extends State<ReplenishmentModal>
    with ItemModal<ReplenishmentModal> {
  final updateData = <String, num>{};
  final List<Ingredient> ingredients = Stock.instance.itemList;

  late TextEditingController _nameController;

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
        child: Text(tt('stock.replenisher.tutorial'), style: textTheme.muted),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSpacing3),
          child: ListView.builder(
            itemBuilder: (_, index) => _fieldIngredient(ingredients[index]),
            itemCount: Stock.instance.length,
          ),
        ),
      ),
    ];

    return form(fields);
  }

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.replenishment?.name);
  }

  @override
  void dispose() {
    _nameController.dispose();

    super.dispose();
  }

  Widget _fieldIngredient(Ingredient ingredient) {
    return TextFormField(
      onSaved: (String? value) {
        final numValue = num.tryParse(value!);
        if (numValue != null && numValue != 0) {
          updateData[ingredient.id] = numValue;
        }
      },
      initialValue:
          widget.replenishment?.getNumOfId(ingredient.id)?.toString() ?? '',
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: ingredient.name,
        hintText: tt('stock.replenisher.hint.amount'),
      ),
    );
  }

  Widget _fieldName(TextTheme textTheme) {
    return TextFormField(
      controller: _nameController,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: tt('stock.replenisher.label.name'),
        hintText: tt('stock.replenisher.hint.name'),
        errorText: errorMessage,
        filled: false,
      ),
      style: textTheme.headline6,
      autofocus: widget.isNew,
      maxLength: 30,
      validator: Validator.textLimit(tt('stock.replenisher.label.name'), 30),
    );
  }

  ReplenishmentObject _parseObject() {
    updateData.clear();
    formKey.currentState!.save();

    return ReplenishmentObject(name: _nameController.text, data: updateData);
  }

  @override
  Future<void> updateItem() async {
    final object = _parseObject();

    if (widget.isNew) {
      final model = Replenishment(name: object.name, data: object.data);

      await Replenisher.instance.setItem(model);
    } else {
      await widget.replenishment!.update(object);
    }

    Navigator.of(context).pop();
  }

  @override
  String? validate() {
    final name = _nameController.text;

    if (widget.replenishment?.name != name &&
        Replenisher.instance.hasName(name)) {
      return tt('stock.replenisher.error.name');
    }
  }
}
