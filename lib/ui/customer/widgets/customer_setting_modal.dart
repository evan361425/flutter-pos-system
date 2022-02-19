import 'package:flutter/material.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/components/style/radio_text.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/objects/customer_object.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/translator.dart';

class CustomerModal extends StatefulWidget {
  final CustomerSetting? setting;

  final bool isNew;

  const CustomerModal({Key? key, this.setting})
      : isNew = setting == null,
        super(key: key);

  @override
  _CustomerModalState createState() => _CustomerModalState();
}

class _CustomerModalModes extends StatefulWidget {
  final CustomerSettingOptionMode selectedMode;

  const _CustomerModalModes({
    Key? key,
    required this.selectedMode,
  }) : super(key: key);

  @override
  _CustomerModalModesState createState() => _CustomerModalModesState();
}

class _CustomerModalModesState extends State<_CustomerModalModes>
    with TickerProviderStateMixin {
  late CustomerSettingOptionMode selectedMode;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        for (final mode in CustomerSettingOptionMode.values)
          Expanded(
            child: RadioText(
              key: Key('customer_setting.modes.${mode.index}'),
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              isSelected: selectedMode == mode,
              onChanged: (_) => setState(() => selectedMode = mode),
              text: S.customerSettingModeNames(mode),
            ),
          )
      ]),
      const SizedBox(height: 8.0),
      Text(S.customerSettingModeDescriptions(selectedMode)),
    ]);
  }

  @override
  void initState() {
    selectedMode = widget.selectedMode;
    super.initState();
  }
}

class _CustomerModalState extends State<CustomerModal>
    with ItemModal<CustomerModal> {
  late TextEditingController _nameController;

  late GlobalKey<_CustomerModalModesState> modesKey;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  List<Widget> formFields() {
    return [
      TextFormField(
        key: const Key('customer_setting.name'),
        controller: _nameController,
        textInputAction: TextInputAction.send,
        textCapitalization: TextCapitalization.words,
        autofocus: widget.isNew,
        decoration: InputDecoration(
          labelText: S.customerSettingNameLabel,
          hintText: S.customerSettingNameHint,
          errorText: errorMessage,
          filled: false,
        ),
        onFieldSubmitted: (_) => handleSubmit(),
        maxLength: 30,
        validator: Validator.textLimit(S.customerSettingNameLabel, 30),
      ),
      TextDivider(label: S.customerSettingModeTitle),
      _CustomerModalModes(
        key: modesKey,
        selectedMode: widget.isNew
            ? CustomerSettingOptionMode.statOnly
            : widget.setting!.mode,
      ),
    ];
  }

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.setting?.name);
    modesKey = GlobalKey<_CustomerModalModesState>();

    super.initState();
  }

  @override
  Future<void> updateItem() async {
    final object = CustomerSettingObject(
      name: _nameController.text,
      mode: modesKey.currentState?.selectedMode ??
          CustomerSettingOptionMode.statOnly,
    );

    if (widget.isNew) {
      await CustomerSettings.instance.addItem(CustomerSetting(
        name: object.name!,
        mode: object.mode!,
        index: CustomerSettings.instance.newIndex,
      ));
    } else {
      await widget.setting!.update(object);
    }

    Navigator.of(context).pop();
  }

  @override
  String? validate() {
    final name = _nameController.text;

    if (widget.setting?.name != name &&
        CustomerSettings.instance.hasName(name)) {
      return S.customerSettingNameRepeatError;
    }

    return null;
  }
}
