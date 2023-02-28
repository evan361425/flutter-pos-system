import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';

class OrderAttributeOptionModal extends StatefulWidget {
  final OrderAttribute attribute;

  final OrderAttributeOption? option;

  final bool isNew;

  const OrderAttributeOptionModal({
    Key? key,
    required this.attribute,
    this.option,
  })  : isNew = option == null,
        super(key: key);

  @override
  State<OrderAttributeOptionModal> createState() => _OrderAttributeModalState();
}

class _OrderAttributeModalState extends State<OrderAttributeOptionModal>
    with ItemModal<OrderAttributeOptionModal> {
  late TextEditingController _nameController;
  late TextEditingController _valueController;
  late FocusNode _nameFocusNode;
  late FocusNode _valueFocusNode;
  late bool isDefault;

  @override
  Widget? get title => Text(widget.isNew
      ? S.orderAttributeOptionCreateTitle(widget.attribute.name)
      : widget.option!.name);

  @override
  List<Widget> buildFormFields() {
    final label = S.orderAttributeModeNames(widget.attribute.mode.name);
    final helper =
        S.orderAttributeOptionsModeHelper(widget.attribute.mode.name);
    final hint = S.orderAttributeOptionsModeHint(widget.attribute.mode.name);
    final validator = widget.attribute.mode == OrderAttributeMode.changeDiscount
        ? Validator.positiveInt(
            label,
            maximum: 1000,
            allowNull: true,
            focusNode: _valueFocusNode,
          )
        : Validator.isNumber(
            label,
            allowNull: true,
            focusNode: _valueFocusNode,
          );

    return [
      TextFormField(
        key: const Key('order_attribute_option.name'),
        controller: _nameController,
        textInputAction: widget.attribute.shouldHaveModeValue
            ? TextInputAction.next
            : TextInputAction.send,
        textCapitalization: TextCapitalization.words,
        autofocus: widget.isNew,
        focusNode: _nameFocusNode,
        decoration: InputDecoration(
          labelText: S.orderAttributeOptionNameLabel,
          helperText: S.orderAttributeOptionNameHelper,
          filled: false,
        ),
        maxLength: 30,
        validator: Validator.textLimit(
          S.orderAttributeOptionNameLabel,
          30,
          focusNode: _nameFocusNode,
          validator: (name) {
            return widget.option?.name != name && widget.attribute.hasName(name)
                ? S.orderAttributeOptionNameRepeatError
                : null;
          },
        ),
      ),
      CheckboxListTile(
        key: const Key('order_attribute_option.isDefault'),
        controlAffinity: ListTileControlAffinity.leading,
        value: isDefault,
        selected: isDefault,
        onChanged: _toggledDefault,
        title: Text(S.orderAttributeOptionSetToDefault),
      ),
      widget.attribute.shouldHaveModeValue
          ? TextFormField(
              key: const Key('order_attribute_option.modeValue'),
              controller: _valueController,
              textInputAction: TextInputAction.send,
              keyboardType: TextInputType.number,
              focusNode: _valueFocusNode,
              decoration: InputDecoration(
                labelText: label,
                helperText: helper,
                hintText: hint,
                filled: false,
              ),
              onFieldSubmitted: (_) => handleSubmit(),
              validator: validator,
            )
          : HintText(helper),
    ];
  }

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.option?.name);
    _valueController = TextEditingController(
      text: widget.option?.modeValue == null
          ? ''
          : widget.attribute.mode == OrderAttributeMode.changeDiscount
              ? widget.option!.modeValue!.toInt().toString()
              : widget.option!.modeValue!.toCurrency(),
    );
    _nameFocusNode = FocusNode();
    _valueFocusNode = FocusNode();

    isDefault = widget.option?.isDefault ?? false;

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _nameFocusNode.dispose();
    _valueFocusNode.dispose();
    super.dispose();
  }

  @override
  Future<void> updateItem() async {
    final object = OrderAttributeOptionObject(
      name: _nameController.text,
      modeValue: num.tryParse(_valueController.text),
      isDefault: isDefault,
    );

    // if turn to default or add default
    if (isDefault && widget.option?.isDefault != true) {
      await widget.attribute.clearDefault();
    }

    if (widget.isNew) {
      await widget.attribute.addItem(OrderAttributeOption(
        name: object.name!,
        index: widget.attribute.newIndex,
        isDefault: isDefault,
        modeValue: object.modeValue,
      ));
    } else {
      await widget.option!.update(object);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _toggledDefault(bool? value) async {
    final defaultOption = widget.attribute.defaultOption;
    // warn if default option is going to changed
    if (value == true &&
        defaultOption != null &&
        defaultOption.id != widget.option?.id) {
      final confirmed = await ConfirmDialog.show(
        context,
        title: S.orderAttributeOptionConfirmChangeDefaultTitle,
        content: S.orderAttributeOptionConfirmChangeDefaultContent(
          defaultOption.name,
        ),
      );

      if (confirmed) {
        setState(() => isDefault = value!);
      }
    } else {
      setState(() => isDefault = value!);
    }
  }
}
