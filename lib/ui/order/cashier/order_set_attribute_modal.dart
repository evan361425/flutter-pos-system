import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/order_attributes.dart';

class OderSetAttributeModal extends StatelessWidget {
  const OderSetAttributeModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(8.0), children: [
      for (final item in OrderAttributes.instance.notEmptyItems)
        _OrderAttributeGroup(item),
    ]);
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
      Text(
        widget.attribute.name,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: kSpacing0),
      Card(
        margin: const EdgeInsets.only(bottom: kSpacing2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSpacing1),
          child: Wrap(spacing: kSpacing0, children: [
            for (final option in widget.attribute.itemList)
              ChoiceChip(
                key: Key('set_attribute.${widget.attribute.id}.${option.id}'),
                onSelected: (selected) {
                  setState(() => selectedId = selected ? option.id : null);
                  selectOption(option, selected);
                },
                selected: selectedId == option.id,
                label: Text(option.name),
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
      // Disable it.
      // If remove it from map, it will choose default one not disabling
      Cart.instance.attributes[widget.attribute.id] = '';
    }
  }
}
