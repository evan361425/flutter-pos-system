import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/translator.dart';

class CheckoutAttributeView extends StatelessWidget {
  final ValueNotifier<num> price;

  const CheckoutAttributeView({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    final noteField = TextField(
      key: const Key('order.attr_note'),
      controller: TextEditingController(text: Cart.instance.note),
      textInputAction: .done,
      decoration: InputDecoration(
        hintText: S.orderCheckoutAttributeNoteHint,
        border: OutlineInputBorder(borderRadius: .circular(8.0)),
      ),
      keyboardType: .multiline,
      maxLength: 200,
      minLines: 2,
      maxLines: 5,
      onChanged: Cart.instance.updateNote,
    );

    return SingleChildScrollView(
      padding: const .fromLTRB(
        kHorizontalSpacing,
        kTopSpacing,
        kHorizontalSpacing,
        kFABSpacing,
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          for (final item in OrderAttributes.instance.notEmptyItems)
            _CheckoutAttributeGroup(item, price),
          Text(
            S.orderCheckoutAttributeNoteTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: kInternalSpacing),
          noteField,
        ],
      ),
    );
  }
}

class _CheckoutAttributeGroup extends StatefulWidget {
  final ValueNotifier<num> price;

  final OrderAttribute attribute;

  const _CheckoutAttributeGroup(this.attribute, this.price);

  @override
  State<_CheckoutAttributeGroup> createState() =>
      _CheckoutAttributeGroupState();
}

class _CheckoutAttributeGroupState extends State<_CheckoutAttributeGroup> {
  late String? selectedId;
  late final TextEditingController customValueController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(_attributeName, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: kInternalSpacing),
        Padding(
          padding: const .symmetric(horizontal: kHorizontalSpacing),
          child: Wrap(
            spacing: kInternalSpacing,
            children: [
              for (final option in widget.attribute.itemList)
                ChoiceChip(
                  key: Key('order.attr.${widget.attribute.id}.${option.id}'),
                  onSelected: (selected) {
                    setState(() => selectedId = selected ? option.id : null);
                    selectOption(option, selected);
                  },
                  selected: selectedId == option.id,
                  label: Text(_optionName(option)),
                ),
            ],
          ),
        ),
        if (widget.attribute.id == 'city' && selectedId == 'other')
          Padding(
            padding: const .symmetric(
              horizontal: kHorizontalSpacing,
              vertical: kInternalSpacing,
            ),
            child: TextField(
              key: const Key('order.attr.city.other'),
              controller: customValueController,
              textCapitalization: .words,
              decoration: InputDecoration(
                labelText: S.orderCustomerCityOtherLabel,
                border: OutlineInputBorder(borderRadius: .circular(8.0)),
              ),
              onChanged: (value) => Cart.instance.updateCustomAttributeValue(
                widget.attribute.id,
                value,
              ),
            ),
          ),
        const SizedBox(height: kInternalLargeSpacing),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    selectedId =
        Cart.instance.attributes[widget.attribute.id] ??
        widget.attribute.defaultOption?.id;
    customValueController = TextEditingController(
      text: Cart.instance.customAttributeValues[widget.attribute.id],
    );
  }

  @override
  void dispose() {
    customValueController.dispose();
    super.dispose();
  }

  void selectOption(OrderAttributeOption option, bool isSelected) {
    Cart.instance.chooseAttribute(
      widget.attribute.id,
      isSelected ? option.id : '',
    );

    widget.price.value = Cart.instance.price;
  }

  String get _attributeName => switch (widget.attribute.id) {
    'city' => S.orderCustomerCity,
    'sale-method' => S.orderCustomerSaleMethod,
    _ => widget.attribute.name,
  };

  String _optionName(OrderAttributeOption option) {
    if (widget.attribute.id == 'city' && option.id == 'other')
      return S.orderCustomerCityOther;
    if (widget.attribute.id == 'sale-method' && option.id == 'pickup')
      return S.orderCustomerSaleMethodPickup;
    if (widget.attribute.id == 'sale-method' && option.id == 'shipping')
      return S.orderCustomerSaleMethodShipping;
    return option.name;
  }
}
