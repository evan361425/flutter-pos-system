import 'package:flutter/material.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/components/style/hint_text.dart';
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
  Widget body() => form(formFields());

  @override
  void dispose() {
    _nameController.dispose();

    super.dispose();
  }

  @override
  List<Widget> formFields() {
    final textTheme = Theme.of(context).textTheme;

    return <Widget>[
      Padding(
        padding: const EdgeInsets.all(kSpacing3),
        child: _fieldName(textTheme),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: kSpacing1),
        child: HintText(S.stockReplenishmentIngredientListTitle),
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
  }

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.replenishment?.name);
  }

  @override
  Future<void> updateItem() async {
    final object = _parseObject();

    if (widget.isNew) {
      await Replenisher.instance.addItem(Replenishment(
        name: object.name,
        data: object.data,
      ));
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
      return S.stockReplenishmentNameRepeatError;
    }
  }

  Widget _fieldIngredient(Ingredient ingredient) {
    return TextFormField(
      key: Key('replenishment.ingredients.${ingredient.id}'),
      onSaved: (String? value) {
        final numValue = num.tryParse(value!);
        if (numValue != null && numValue != 0) {
          updateData[ingredient.id] = numValue;
        }
      },
      initialValue: widget.replenishment?.getNumOfId(ingredient.id)?.toString(),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: ingredient.name,
        hintText: S.stockReplenishmentNameHint,
      ),
    );
  }

  Widget _fieldName(TextTheme textTheme) {
    return TextFormField(
      key: const Key('replenishment.name'),
      controller: _nameController,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: S.stockReplenishmentNameLabel,
        hintText: S.stockReplenishmentNameHint,
        errorText: errorMessage,
        filled: false,
      ),
      style: textTheme.headline6,
      autofocus: widget.isNew,
      maxLength: 30,
      validator: Validator.textLimit(S.stockReplenishmentNameLabel, 60),
    );
  }

  ReplenishmentObject _parseObject() {
    updateData.clear();
    formKey.currentState!.save();

    return ReplenishmentObject(name: _nameController.text, data: updateData);
  }
}
