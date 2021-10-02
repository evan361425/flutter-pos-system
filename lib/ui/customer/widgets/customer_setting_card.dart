import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/components/style/expansion_action_button.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/objects/customer_object.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

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
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(children: [
              for (final item in setting.items)
                Container(
                  margin: const EdgeInsets.only(bottom: 4.0),
                  child: OutlinedText(
                    item.name,
                    colored: item.isDefault,
                  ),
                )
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              ExpansionActionButton(
                onPressed: () => Navigator.of(context).pushNamed(
                  Routes.customerSetting,
                  arguments: setting,
                ),
                icon: Icon(Icons.description_sharp),
                label: Text('查看細節'),
              ),
              ExpansionActionButton(
                isDanger: true,
                onPressed: () => DeleteDialog.show(
                  context,
                  deleteCallback: setting.remove,
                  warningContent: Text(
                    tt('delete_confirm', {'name': setting.name}),
                  ),
                ),
                icon: Icon(KIcons.delete),
                label: Text('刪除設定'),
              ),
            ]),
          ],
        ),
      ]),
    );
  }
}
