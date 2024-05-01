import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/order_attributes.dart';

class CheckoutAttributeView extends StatelessWidget {
  final ValueNotifier<num> price;

  const CheckoutAttributeView({
    super.key,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 428),
      children: [
        for (final item in OrderAttributes.instance.notEmptyItems) _CheckoutAttributeGroup(item, price),
      ],
    );
  }
}

class _CheckoutAttributeGroup extends StatefulWidget {
  final ValueNotifier<num> price;

  final OrderAttribute attribute;

  const _CheckoutAttributeGroup(this.attribute, this.price);

  @override
  State<_CheckoutAttributeGroup> createState() => _CheckoutAttributeGroupState();
}

class _CheckoutAttributeGroupState extends State<_CheckoutAttributeGroup> {
  late String? selectedId;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(
        widget.attribute.name,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: kSpacing0),
      Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 14.0, 10.0, 14.0),
        child: Wrap(spacing: kSpacing0, children: [
          for (final option in widget.attribute.itemList)
            ChoiceChip(
              key: Key('order.attr.${widget.attribute.id}.${option.id}'),
              onSelected: (selected) {
                setState(() => selectedId = selected ? option.id : null);
                selectOption(option, selected);
              },
              selected: selectedId == option.id,
              label: Text(option.name),
            )
        ]),
      ),
    ]);
  }

  @override
  void initState() {
    super.initState();
    selectedId = Cart.instance.attributes[widget.attribute.id] ?? widget.attribute.defaultOption?.id;
  }

  void selectOption(OrderAttributeOption option, bool isSelected) {
    Cart.instance.chooseAttribute(
      widget.attribute.id,
      isSelected ? option.id : '',
    );

    widget.price.value = Cart.instance.price;
  }
}
