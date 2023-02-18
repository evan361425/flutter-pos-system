import 'package:flutter/material.dart';
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
  late TextEditingController _nameController;
  late FocusNode _nameFocusNode;

  late GlobalKey<_ModeSelectorState> modesKey;

  @override
  List<Widget> buildFormFields() {
    return [
      TextFormField(
        key: const Key('order_attribute.name'),
        controller: _nameController,
        textInputAction: TextInputAction.send,
        textCapitalization: TextCapitalization.words,
        autofocus: widget.isNew,
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
      ),
      TextDivider(label: S.orderAttributeModeTitle),
      _ModeSelector(
        key: modesKey,
        selectedMode:
            widget.isNew ? OrderAttributeMode.statOnly : widget.attribute!.mode,
      ),
    ];
  }

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.attribute?.name);
    _nameFocusNode = FocusNode();
    modesKey = GlobalKey<_ModeSelectorState>();

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
      mode: modesKey.currentState?.selectedMode ?? OrderAttributeMode.statOnly,
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

class _ModeSelector extends StatefulWidget {
  final OrderAttributeMode selectedMode;

  const _ModeSelector({
    Key? key,
    required this.selectedMode,
  }) : super(key: key);

  @override
  State<_ModeSelector> createState() => _ModeSelectorState();
}

class _ModeSelectorState extends State<_ModeSelector> {
  late OrderAttributeMode selectedMode;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 4, runSpacing: 4, children: [
        for (final mode in OrderAttributeMode.values)
          ChoiceChip(
            key: Key('order_attribute.modes.${mode.index}'),
            selected: selectedMode == mode,
            onSelected: (selected) {
              if (selected) {
                setState(() => selectedMode = mode);
              }
            },
            label: Text(S.orderAttributeModeNames(mode.name)),
          ),
      ]),
      // infinity width to maximum the column width
      const SizedBox(height: 8.0, width: double.infinity),
      Text(S.orderAttributeModeDescriptions(selectedMode.name)),
    ]);
  }

  @override
  void initState() {
    selectedMode = widget.selectedMode;
    super.initState();
  }
}
