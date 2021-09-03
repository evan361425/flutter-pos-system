import 'package:flutter/material.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/customer/customer_setting_option.dart';
import 'package:possystem/models/objects/customer_object.dart';
import 'package:possystem/models/repository/customers.dart';

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

  @override
  Widget? get title =>
      Text(widget.isNew ? '新增${widget.setting.name}的選項' : widget.option!.name);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.option?.name);

    super.initState();
  }

  @override
  List<Widget> formFields() {
    return [
      TextFormField(
        controller: _nameController,
        textInputAction: TextInputAction.send,
        textCapitalization: TextCapitalization.words,
        autofocus: true,
        decoration: InputDecoration(
          labelText: '顧客設定選項',
          helperText: '以年齡為例，可能的選項有：\n20 歲以下\n20 到 30 歲',
          errorText: errorMessage,
          filled: false,
        ),
        onFieldSubmitted: (_) => handleSubmit(),
        maxLength: 30,
        validator: Validator.textLimit('選項名稱', 30),
      ),
    ];
  }

  @override
  Future<void> updateItem() async {
    final object = CustomerSettingOptionObject(
      name: _nameController.text,
    );

    if (widget.isNew) {
      final option = CustomerSettingOption(
        name: object.name!,
        setting: widget.setting,
        index: widget.setting.newIndex,
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

    if (widget.option?.name != name &&
        CustomerSettings.instance.hasName(name)) {
      return '名稱不能重複';
    }
  }
}
