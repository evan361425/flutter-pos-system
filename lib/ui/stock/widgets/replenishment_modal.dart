import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/scaffold/item_modal.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/text_divider.dart';
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

  const ReplenishmentModal({super.key, this.replenishment}) : isNew = replenishment == null;

  @override
  State<ReplenishmentModal> createState() => _ReplenishmentModalState();
}

class _ReplenishmentModalState extends State<ReplenishmentModal> with ItemModal<ReplenishmentModal> {
  final updateData = <String, num>{};
  final List<Ingredient> ingredients = Stock.instance.itemList;

  late TextEditingController _nameController;
  late FocusNode _nameFocusNode;

  @override
  String get title => widget.isNew ? S.stockReplenishmentTitleCreate : S.stockReplenishmentTitleUpdate;

  @override
  List<Widget> buildFormFields() {
    final textTheme = Theme.of(context).textTheme;

    return <Widget>[
      p(TextFormField(
        key: const Key('replenishment.name'),
        controller: _nameController,
        textInputAction: TextInputAction.done,
        textCapitalization: TextCapitalization.words,
        focusNode: _nameFocusNode,
        decoration: InputDecoration(
          labelText: S.stockReplenishmentNameLabel,
          hintText: widget.replenishment?.name ?? S.stockReplenishmentNameHint,
          filled: false,
        ),
        style: textTheme.titleLarge,
        maxLength: 30,
        validator: Validator.textLimit(
          S.stockReplenishmentNameLabel,
          30,
          focusNode: _nameFocusNode,
          validator: (name) {
            return widget.replenishment?.name != name && Replenisher.instance.hasName(name)
                ? S.stockReplenishmentNameErrorRepeat
                : null;
          },
        ),
      )),
      TextDivider(label: S.stockReplenishmentIngredientsDivider),
      HintText(S.stockReplenishmentIngredientsHelper),
      for (final ing in Stock.instance.itemList) _buildIngredientField(ing),
    ];
  }

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.replenishment?.name);
    _nameFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();

    super.dispose();
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

    if (mounted && context.canPop()) {
      context.pop();
    }
  }

  Widget _buildIngredientField(Ingredient ingredient) {
    return p(TextFormField(
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
        hintText: S.stockReplenishmentIngredientAmountHint,
      ),
    ));
  }

  ReplenishmentObject _parseObject() {
    updateData.clear();
    formKey.currentState!.save();

    return ReplenishmentObject(name: _nameController.text, data: updateData);
  }
}
