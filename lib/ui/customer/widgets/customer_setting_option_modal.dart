import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/customer/customer_setting_option.dart';
import 'package:possystem/models/objects/customer_object.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';

class CustomerSettingOptionModal extends StatefulWidget {
  final CustomerSetting setting;

  final CustomerSettingOption? option;

  final bool isNew;

  const CustomerSettingOptionModal({
    Key? key,
    required this.setting,
    this.option,
  })  : isNew = option == null,
        super(key: key);

  @override
  _CustomerModalState createState() => _CustomerModalState();
}

class _CustomerModalState extends State<CustomerSettingOptionModal>
    with ItemModal<CustomerSettingOptionModal> {
  late TextEditingController _nameController;
  late TextEditingController _modeValueController;
  late bool isDefault;

  @override
  Widget? get title => Text(widget.isNew
      ? S.customerSettingOptionCreateTitle(widget.setting.name)
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
          : widget.setting.mode == CustomerSettingOptionMode.changeDiscount
              ? widget.option!.modeValue!.toInt().toString()
              : widget.option!.modeValue!.toCurrency(),
    );
    isDefault = widget.option?.isDefault ?? false;

    super.initState();
  }

  @override
  List<Widget> formFields() {
    final label = S.customerSettingModeNames(widget.setting.mode);
    final helper = S.customerSettingOptionsModeHelper(widget.setting.mode);
    final hint = S.customerSettingOptionsModeHint(widget.setting.mode);
    final validator =
        widget.setting.mode == CustomerSettingOptionMode.changeDiscount
            ? Validator.positiveInt(label, maximum: 1000, allowNull: true)
            : Validator.isNumber(label, allowNull: true);

    return [
      TextFormField(
        key: const Key('customer_setting_option.name'),
        controller: _nameController,
        textInputAction: widget.setting.shouldHaveModeValue
            ? TextInputAction.next
            : TextInputAction.send,
        textCapitalization: TextCapitalization.words,
        autofocus: widget.isNew,
        decoration: InputDecoration(
          labelText: S.customerSettingOptionNameLabel,
          helperText: S.customerSettingOptionNameHelper,
          errorText: errorMessage,
          filled: false,
        ),
        maxLength: 30,
        validator: Validator.textLimit(S.customerSettingOptionNameLabel, 50),
      ),
      CheckboxListTile(
        key: const Key('customer_setting_option.isDefault'),
        controlAffinity: ListTileControlAffinity.leading,
        value: isDefault,
        selected: isDefault,
        onChanged: toggledDefault,
        title: Text(S.customerSettingOptionSetToDefault),
      ),
      widget.setting.shouldHaveModeValue
          ? TextFormField(
              key: const Key('customer_setting_option.modeValue'),
              controller: _modeValueController,
              textInputAction: TextInputAction.send,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: label,
                helperText: helper,
                hintText: hint,
                errorText: errorMessage,
                filled: false,
              ),
              onFieldSubmitted: (_) => handleSubmit(),
              validator: validator,
            )
          : HintText(helper),
    ];
  }

  void toggledDefault(bool? value) async {
    final defaultOption = widget.setting.defaultOption;
    // warn if default option is going to changed
    if (value == true &&
        defaultOption != null &&
        defaultOption.id != widget.option?.id) {
      final confirmed = await showDialog(
        context: context,
        builder: (_) => ConfirmDialog(
          title: S.customerSettingOptionConfirmChangeDefaultTitle,
          content: Text(S.customerSettingOptionConfirmChangeDefaultContent(
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
    final object = CustomerSettingOptionObject(
      name: _nameController.text,
      modeValue: num.tryParse(_modeValueController.text),
      isDefault: isDefault,
    );

    // if turn to default or add default
    if (isDefault && widget.option?.isDefault != true) {
      await widget.setting.clearDefault();
    }

    if (widget.isNew) {
      await widget.setting.addItem(CustomerSettingOption(
        name: object.name!,
        index: widget.setting.newIndex,
        isDefault: isDefault,
        modeValue: object.modeValue,
      ));
    } else {
      await widget.option!.update(object);
    }

    Navigator.of(context).pop();
  }

  @override
  String? validate() {
    final name = _nameController.text;

    if (widget.option?.name != name && widget.setting.hasName(name)) {
      return S.customerSettingOptionNameRepeatError;
    }
  }
}
