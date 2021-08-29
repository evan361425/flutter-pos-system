import 'package:flutter/material.dart';
import 'package:possystem/components/radio_text.dart';
import 'package:possystem/models/objects/customer_object.dart';

class CustomerModalModes extends StatefulWidget {
  final CustomerSettingOptionMode selectedMode;

  const CustomerModalModes({
    Key? key,
    required this.selectedMode,
  }) : super(key: key);

  @override
  CustomerModalModesState createState() => CustomerModalModesState();
}

class CustomerModalModesState extends State<CustomerModalModes>
    with TickerProviderStateMixin {
  static const titles = <CustomerSettingOptionMode, String>{
    CustomerSettingOptionMode.statOnly: '一般',
    CustomerSettingOptionMode.changePrice: '變價',
    CustomerSettingOptionMode.changeDiscount: '折扣',
  };

  static const descriptions = <CustomerSettingOptionMode, String>{
    CustomerSettingOptionMode.statOnly: '一般的設定，選取時並不會影響點單價格。',
    CustomerSettingOptionMode.changePrice:
        '選取設定時，可能會影響價格。例如：外送 + 30塊錢、環保杯 - 5塊錢。',
    CustomerSettingOptionMode.changeDiscount:
        '選取設定時，會根據折扣影響總價。例如：內用 + 10% 服務費、親友價 - 10%。',
  };

  late CustomerSettingOptionMode selectedMode;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        for (final mode in CustomerSettingOptionMode.values)
          Expanded(
            child: RadioText(
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              groupId: 'customer.setting.mode',
              isSelected: selectedMode == mode,
              onSelected: (_) => setState(() => selectedMode = mode),
              value: mode.toString(),
              text: titles[mode]!,
            ),
          )
      ]),
      const SizedBox(height: 8.0),
      Text(descriptions[selectedMode]!),
    ]);
  }

  @override
  void initState() {
    selectedMode = widget.selectedMode;
    super.initState();
  }
}
