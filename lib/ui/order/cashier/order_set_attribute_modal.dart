import 'package:flutter/material.dart';
import 'package:possystem/components/style/radio_text.dart';
import 'package:possystem/components/style/appbar_text_button.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class OderSetAttributeModal extends StatelessWidget {
  const OderSetAttributeModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PopButton(),
        title: Text(S.orderSetAttributeTitle),
        actions: [
          AppbarTextButton(
            key: const Key('set_attribute.next'),
            onPressed: () => Navigator.of(context).pop(Routes.orderCalculator),
            child: Text(S.orderSetAttributeActionsDone),
          ),
        ],
      ),
      body: Padding(
        // bottom for floating button
        padding: const EdgeInsets.all(kSpacing2),
        child: ListView(children: [
          for (final item in OrderAttributes.instance.notEmptyItems)
            _OrderAttributeGroup(item),
        ]),
      ),
    );
  }
}

class _OrderAttributeGroup extends StatefulWidget {
  final OrderAttribute attribute;

  const _OrderAttributeGroup(this.attribute);

  @override
  State<_OrderAttributeGroup> createState() => _OrderAttributeGroupState();
}

class _OrderAttributeGroupState extends State<_OrderAttributeGroup> {
  late String? selectedId;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(widget.attribute.name, style: Theme.of(context).textTheme.headline5),
      const SizedBox(height: kSpacing0),
      Card(
        margin: const EdgeInsets.only(bottom: kSpacing2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSpacing1),
          child: Wrap(spacing: kSpacing0, children: [
            for (final option in widget.attribute.itemList)
              RadioText(
                key: Key('set_attribute.${widget.attribute.id}.${option.id}'),
                onChanged: (isSelected) {
                  setState(() => selectedId = isSelected ? option.id : null);
                  selectOption(option, isSelected);
                },
                isTogglable: true,
                isSelected: selectedId == option.id,
                text: option.name,
              )
          ]),
        ),
      ),
    ]);
  }

  @override
  void initState() {
    super.initState();
    selectedId = Cart.instance.attributes[widget.attribute.id] ??
        widget.attribute.defaultOption?.id;
  }

  void selectOption(OrderAttributeOption option, bool isSelected) {
    if (isSelected) {
      Cart.instance.attributes[widget.attribute.id] = option.id;
    } else {
      // disable it
      Cart.instance.attributes[widget.attribute.id] = '';
    }
  }
}
