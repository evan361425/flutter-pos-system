import 'package:flutter/material.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/components/style/radio_text.dart';
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
  OrderAttributeModalState createState() => OrderAttributeModalState();
}

class _ModalModes extends StatefulWidget {
  final OrderAttributeMode selectedMode;

  const _ModalModes({
    Key? key,
    required this.selectedMode,
  }) : super(key: key);

  @override
  OrderAttributeModalModesState createState() =>
      OrderAttributeModalModesState();
}

class OrderAttributeModalModesState extends State<_ModalModes>
    with TickerProviderStateMixin {
  late OrderAttributeMode selectedMode;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        for (final mode in OrderAttributeMode.values)
          Expanded(
            child: RadioText(
              key: Key('order_attribute.modes.${mode.index}'),
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              isSelected: selectedMode == mode,
              onChanged: (_) => setState(() => selectedMode = mode),
              text: S.orderAttributeModeNames(mode),
            ),
          )
      ]),
      const SizedBox(height: 8.0),
      Text(S.orderAttributeModeDescriptions(selectedMode)),
    ]);
  }

  @override
  void initState() {
    selectedMode = widget.selectedMode;
    super.initState();
  }
}

class OrderAttributeModalState extends State<OrderAttributeModal>
    with ItemModal<OrderAttributeModal> {
  late TextEditingController _nameController;

  late GlobalKey<OrderAttributeModalModesState> modesKey;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  List<Widget> formFields() {
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
          errorText: errorMessage,
          filled: false,
        ),
        onFieldSubmitted: (_) => handleSubmit(),
        maxLength: 30,
        validator: Validator.textLimit(S.orderAttributeNameLabel, 30),
      ),
      TextDivider(label: S.orderAttributeModeTitle),
      _ModalModes(
        key: modesKey,
        selectedMode:
            widget.isNew ? OrderAttributeMode.statOnly : widget.attribute!.mode,
      ),
    ];
  }

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.attribute?.name);
    modesKey = GlobalKey<OrderAttributeModalModesState>();

    super.initState();
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

  @override
  String? validate() {
    final name = _nameController.text;

    if (widget.attribute?.name != name &&
        OrderAttributes.instance.hasName(name)) {
      return S.orderAttributeNameRepeatError;
    }

    return null;
  }
}
