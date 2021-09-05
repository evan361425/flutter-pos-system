import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/customer/customer_setting_option.dart';
import 'package:possystem/models/objects/customer_object.dart';

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
  Widget? get title =>
      Text(widget.isNew ? '新增${widget.setting.name}的選項' : widget.option!.name);

  @override
  void dispose() {
    _nameController.dispose();
    _modeValueController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.option?.name);
    _modeValueController =
        TextEditingController(text: widget.option?.modeValue.toString() ?? '');
    isDefault = widget.option?.isDefault ?? false;

    super.initState();
  }

  @override
  List<Widget> formFields() {
    final modeValueLabel =
        widget.setting.mode == CustomerSettingOptionMode.changeDiscount
            ? '折價'
            : '變價';
    final modeValueHelper =
        widget.setting.mode == CustomerSettingOptionMode.changeDiscount
            ? '點單時選擇此項會套用此折價'
            : '點單時選擇此項會套用此變價';
    final modeValueHint =
        widget.setting.mode == CustomerSettingOptionMode.changeDiscount
            ? '80 代表「八折」'
            : '-30 代表減少三十塊';
    final modeValueValidator =
        widget.setting.mode == CustomerSettingOptionMode.changeDiscount
            ? Validator.positiveInt('折價', maximum: 100, allowNull: true)
            : Validator.isNumber('變價', allowNull: true);

    return [
      TextFormField(
        controller: _nameController,
        textInputAction: widget.setting.shouldHaveModeValue
            ? TextInputAction.next
            : TextInputAction.send,
        textCapitalization: TextCapitalization.words,
        autofocus: widget.isNew,
        decoration: InputDecoration(
          labelText: '顧客設定選項',
          helperText: '以年齡為例，可能的選項有：\n- 20 歲以下\n- 20 到 30 歲',
          errorText: errorMessage,
          filled: false,
        ),
        maxLength: 30,
        validator: Validator.textLimit('選項名稱', 50),
      ),
      CheckboxListTile(
        value: isDefault,
        selected: isDefault,
        onChanged: toggledDefault,
        title: Text('設為預設'),
      ),
      Divider(),
      widget.setting.shouldHaveModeValue
          ? TextFormField(
              controller: _modeValueController,
              textInputAction: TextInputAction.send,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: modeValueLabel,
                helperText: modeValueHelper,
                hintText: modeValueHint,
                errorText: errorMessage,
                filled: false,
              ),
              onFieldSubmitted: (_) => handleSubmit(),
              validator: modeValueValidator,
            )
          : HintText('因為本設定為「一般」故無須設定「折價」或「變價」'),
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
          title: '確定要覆蓋預設值嗎',
          content: Text('這麼做會讓「${defaultOption.name}」變成非預設值'),
        ),
      );

      if (confirmed != true) return;
    }
    setState(() => isDefault = value ?? false);
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
      final option = CustomerSettingOption(
        name: object.name!,
        setting: widget.setting,
        index: widget.setting.newIndex,
        isDefault: isDefault,
        modeValue: object.modeValue,
      );

      await widget.setting.setItem(option);
    } else {
      await widget.option!.update(object);
    }

    Navigator.of(context).pop();
  }

  @override
  String? validate() {
    final name = _nameController.text;

    if (widget.option?.name != name && widget.setting.hasName(name)) {
      return '名稱不能重複';
    }
  }
}
