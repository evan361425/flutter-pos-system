import 'package:flutter/material.dart';
import 'package:possystem/components/choice_chip_with_help.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/translator.dart';

class OrderAttributeModal extends StatefulWidget {
  final OrderAttribute? attribute;

  final bool isNew;

  const OrderAttributeModal({Key? key, this.attribute})
      : isNew = attribute == null,
        super(key: key);

  @override
  State<OrderAttributeModal> createState() => _OrderAttributeModalState();
}

class _OrderAttributeModalState extends State<OrderAttributeModal>
    with ItemModal<OrderAttributeModal> {
  late final TextEditingController _nameController;

  final FocusNode _nameFocusNode = FocusNode();
  final modeSelector = GlobalKey<ChoiceChipWithHelpState<OrderAttributeMode>>();

  @override
  String get title => widget.attribute?.name ?? S.orderAttributeCreate;

  @override
  List<Widget> buildFormFields() {
    return [
      p(TextFormField(
        key: const Key('order_attribute.name'),
        controller: _nameController,
        textInputAction: TextInputAction.send,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: S.orderAttributeNameLabel,
          hintText: S.orderAttributeNameHint,
          filled: false,
        ),
        onFieldSubmitted: (_) => handleSubmit(),
        maxLength: 30,
        validator: Validator.textLimit(
          S.orderAttributeNameLabel,
          30,
          focusNode: _nameFocusNode,
          validator: (name) {
            return widget.attribute?.name != name &&
                    OrderAttributes.instance.hasName(name)
                ? S.orderAttributeNameRepeatError
                : null;
          },
        ),
      )),
      TextDivider(label: S.orderAttributeModeTitle),
      ChoiceChipWithHelp(
        key: modeSelector,
        values: OrderAttributeMode.values,
        selected:
            widget.isNew ? OrderAttributeMode.statOnly : widget.attribute!.mode,
        labels: OrderAttributeMode.values
            .map((e) => S.orderAttributeModeNames(e.name)),
        helpTexts: OrderAttributeMode.values
            .map((e) => S.orderAttributeModeDescriptions(e.name))
            .toList(),
      ),
    ];
  }

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.attribute?.name);
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Future<void> updateItem() async {
    final object = OrderAttributeObject(
      name: _nameController.text,
      mode: modeSelector.currentState?.selected ?? OrderAttributeMode.statOnly,
    );

    if (widget.isNew) {
      await OrderAttributes.instance.addItem(OrderAttribute(
        name: object.name!,
        mode: object.mode!,
        index: OrderAttributes.instance.newIndex,
      ));
    } else {
      await widget.attribute!.update(object);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
