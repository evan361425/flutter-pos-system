import 'package:flutter/material.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/objects/customer_object.dart';
import 'package:possystem/models/repository/customers.dart';
import 'package:possystem/routes.dart';

class CustomerModal extends StatefulWidget {
  final CustomerSetting? setting;

  final bool isNew;

  CustomerModal({Key? key, this.setting})
      : isNew = setting == null,
        super(key: key);

  @override
  _CustomerModalState createState() => _CustomerModalState();
}

class _CustomerModalState extends State<CustomerModal>
    with ItemModal<CustomerModal> {
  late TextEditingController _nameController;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.setting?.name);
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
          labelText: '顧客設定名稱',
          hintText: '年齡',
          errorText: errorMessage,
          filled: false,
        ),
        onFieldSubmitted: (_) => handleSubmit(),
        maxLength: 30,
        validator: Validator.textLimit('顧客設定名稱', 30),
      )
    ];
  }

  Future<CustomerSetting> getSetting() async {
    final object = CustomerSettingObject(name: _nameController.text);

    if (widget.isNew) {
      final setting = CustomerSetting(
        name: object.name!,
        index: Customers.instance.newIndex,
        options: [CustomerSettingOption(name: 'a')],
      );

      await Customers.instance.setItem(setting);
      return setting;
    } else {
      await widget.setting!.update(object);
      return widget.setting!;
    }
  }

  @override
  Future<void> updateItem() async {
    final setting = await getSetting();

    // go to catalog screen
    widget.isNew
        ? Navigator.of(context).popAndPushNamed(
            Routes.customerSetting,
            arguments: setting,
          )
        : Navigator.of(context).pop();
  }

  @override
  String? validate() {
    final name = _nameController.text;

    if (widget.setting?.name != name && Customers.instance.hasName(name)) {
      return '名稱不能重複';
    }
  }
}
