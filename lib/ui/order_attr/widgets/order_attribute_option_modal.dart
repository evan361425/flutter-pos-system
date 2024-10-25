import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/scaffold/item_modal.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/translator.dart';

class OrderAttributeOptionModal extends StatefulWidget {
  final OrderAttribute attribute;

  final OrderAttributeOption? option;

  final bool isNew;

  const OrderAttributeOptionModal(
    this.attribute, {
    super.key,
    this.option,
  }) : isNew = option == null;

  @override
  State<OrderAttributeOptionModal> createState() => _OrderAttributeModalState();
}

class _OrderAttributeModalState extends State<OrderAttributeOptionModal> with ItemModal<OrderAttributeOptionModal> {
  late TextEditingController _nameController;
  late TextEditingController _valueController;
  late FocusNode _nameFocusNode;
  late FocusNode _valueFocusNode;
  late bool isDefault;

  @override
  String get title => widget.isNew ? S.orderAttributeOptionTitleCreate : S.orderAttributeOptionTitleUpdate;

  @override
  List<Widget> buildFormFields() {
    final label = S.orderAttributeModeName(widget.attribute.mode.name);
    final helper = S.orderAttributeOptionModeHelper(widget.attribute.mode.name);
    final hint = S.orderAttributeOptionModeHint(widget.attribute.mode.name);
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
      HintText(S.orderAttributeOptionMetaOptionOf(widget.attribute.name)),
      p(TextFormField(
        key: const Key('order_attribute_option.name'),
        controller: _nameController,
        textInputAction: widget.attribute.shouldHaveModeValue ? TextInputAction.next : TextInputAction.send,
        textCapitalization: TextCapitalization.words,
        focusNode: _nameFocusNode,
        decoration: InputDecoration(
          labelText: S.orderAttributeOptionNameLabel,
          hintText: widget.option?.name,
          helperText: S.orderAttributeOptionNameHelper,
          helperMaxLines: 3,
          filled: false,
        ),
        maxLength: 30,
        validator: Validator.textLimit(
          S.orderAttributeOptionNameLabel,
          30,
          focusNode: _nameFocusNode,
          validator: (name) {
            return widget.option?.name != name && widget.attribute.hasName(name)
                ? S.orderAttributeOptionNameErrorRepeat
                : null;
          },
        ),
      )),
      CheckboxListTile(
        key: const Key('order_attribute_option.isDefault'),
        controlAffinity: ListTileControlAffinity.leading,
        value: isDefault,
        selected: isDefault,
        onChanged: _toggledDefault,
        title: Text(S.orderAttributeOptionToDefaultLabel),
      ),
      p(widget.attribute.shouldHaveModeValue
          ? TextFormField(
              key: const Key('order_attribute_option.modeValue'),
              controller: _valueController,
              textInputAction: TextInputAction.send,
              keyboardType: TextInputType.number,
              focusNode: _valueFocusNode,
              decoration: InputDecoration(
                labelText: label,
                helperText: helper,
                helperMaxLines: 3,
                hintText: hint,
                filled: false,
              ),
              onFieldSubmitted: handleFieldSubmit,
              validator: validator,
            )
          : Center(child: HintText(helper))),
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

    if (mounted && context.canPop()) {
      context.pop();
    }
  }

  void _toggledDefault(bool? value) async {
    final defaultOption = widget.attribute.defaultOption;
    // warn if default option is going to changed
    if (value == true && defaultOption != null && defaultOption.id != widget.option?.id) {
      final confirmed = await ConfirmDialog.show(
        context,
        title: S.orderAttributeOptionToDefaultConfirmChangeTitle,
        content: S.orderAttributeOptionToDefaultConfirmChangeContent(defaultOption.name),
      );

      if (confirmed) {
        setState(() => isDefault = value!);
      }
    } else {
      setState(() => isDefault = value!);
    }
  }
}
