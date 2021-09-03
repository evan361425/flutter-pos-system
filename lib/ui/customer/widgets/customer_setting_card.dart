import 'package:flutter/material.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/objects/customer_object.dart';

class CustomerSettingCard extends StatelessWidget {
  final CustomerSetting setting;

  const CustomerSettingCard({
    Key? key,
    required this.setting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mode = customerSettingOptionModeString[setting.mode];
    final defaultName = setting.defaultOption?.name ?? '無';

    return Card(
      child: Column(children: <Widget>[
        ExpansionTile(
          title: Text(setting.name),
          subtitle: Text('種類：$mode\n預設：$defaultName'),
          childrenPadding: const EdgeInsets.all(kSpacing2),
          expandedAlignment: Alignment.centerLeft,
          children: <Widget>[
            Wrap(spacing: kSpacing1, children: [
              for (final option in setting.options)
                OutlinedText(
                  option.name,
                  colored: option.isDefault,
                )
            ])
          ],
        ),
      ]),
    );
  }
}
