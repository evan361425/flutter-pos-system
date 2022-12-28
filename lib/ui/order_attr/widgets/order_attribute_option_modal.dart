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
  OrderAttributeModalState createState() => OrderAttributeModalState();
}

class OrderAttributeModalState extends State<OrderAttributeOptionModal>
    with ItemModal<OrderAttributeOptionModal> {
  late TextEditingController _nameController;
  late TextEditingController _modeValueController;
  late bool isDefault;

  @override
  Widget? get title => Text(widget.isNew
      ? S.orderAttributeOptionCreateTitle(widget.attribute.name)
      : widget.option!.name);

  @override
  void dispose() {
    _nameController.dispose();
    _modeValueController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.option?.name);
    _modeValueController = TextEditingController(
      text: widget.option?.modeValue == null
          ? ''
          : widget.attribute.mode == OrderAttributeMode.changeDiscount
              ? widget.option!.modeValue!.toInt().toString()
              : widget.option!.modeValue!.toCurrency(),
    );
    isDefault = widget.option?.isDefault ?? false;

    super.initState();
  }

  @override
  List<Widget> formFields() {
    final label = S.orderAttributeModeNames(widget.attribute.mode);
    final helper = S.orderAttributeOptionsModeHelper(widget.attribute.mode);
    final hint = S.orderAttributeOptionsModeHint(widget.attribute.mode);
    final validator = widget.attribute.mode == OrderAttributeMode.changeDiscount
        ? Validator.positiveInt(label, maximum: 1000, allowNull: true)
        : Validator.isNumber(label, allowNull: true);

    return [
      TextFormField(
        key: const Key('order_attribute_option.name'),
        controller: _nameController,
        textInputAction: widget.attribute.shouldHaveModeValue
            ? TextInputAction.next
            : TextInputAction.send,
        textCapitalization: TextCapitalization.words,
        autofocus: widget.isNew,
        decoration: InputDecoration(
          labelText: S.orderAttributeOptionNameLabel,
          helperText: S.orderAttributeOptionNameHelper,
          errorText: errorMessage,
          filled: false,
        ),
        maxLength: 30,
        validator: Validator.textLimit(S.orderAttributeOptionNameLabel, 30),
      ),
      CheckboxListTile(
        key: const Key('order_attribute_option.isDefault'),
        controlAffinity: ListTileControlAffinity.leading,
        value: isDefault,
        selected: isDefault,
        onChanged: toggledDefault,
        title: Text(S.orderAttributeOptionSetToDefault),
      ),
      widget.attribute.shouldHaveModeValue
          ? TextFormField(
              key: const Key('order_attribute_option.modeValue'),
              controller: _modeValueController,
              textInputAction: TextInputAction.send,
              keyboardType: TextInputType.number,
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

  void toggledDefault(bool? value) async {
    final defaultOption = widget.attribute.defaultOption;
    // warn if default option is going to changed
    if (value == true &&
        defaultOption != null &&
        defaultOption.id != widget.option?.id) {
      final confirmed = await showDialog(
        context: context,
        builder: (_) => ConfirmDialog(
          title: S.orderAttributeOptionConfirmChangeDefaultTitle,
          content: Text(S.orderAttributeOptionConfirmChangeDefaultContent(
              defaultOption.name)),
        ),
      );

      if (confirmed == true) {
        setState(() => isDefault = value!);
      }
    } else {
      setState(() => isDefault = value!);
    }
  }

  @override
  Future<void> updateItem() async {
    final object = OrderAttributeOptionObject(
      name: _nameController.text,
      modeValue: num.tryParse(_modeValueController.text),
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

  @override
  String? validate() {
    final name = _nameController.text;

    if (widget.option?.name != name && widget.attribute.hasName(name)) {
      return S.orderAttributeOptionNameRepeatError;
    }

    return null;
  }
}
