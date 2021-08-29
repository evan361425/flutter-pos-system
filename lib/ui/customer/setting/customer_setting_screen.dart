import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/icon_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/ui/customer/widgets/customer_modal_modes.dart';

import '../../../routes.dart';

class CustomerSettingScreen extends StatelessWidget {
  final CustomerSetting setting;

  const CustomerSettingScreen({Key? key, required this.setting})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metadata = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Tooltip(
          message: '顧客設定種類',
          child: IconText(
            text: CustomerModalModesState.titles[setting.mode]!,
            icon: Icons.settings_sharp,
          ),
        ),
      ],
    );

    return Scaffold(
        appBar: AppBar(
          title: Text(setting.name),
          leading: PopButton(),
          actions: [
            IconButton(
              onPressed: () => showCircularBottomSheet(
                context,
                actions: _actions(),
              ),
              icon: Icon(KIcons.more),
            ),
          ],
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(kSpacing3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(setting.name, style: theme.textTheme.headline4),
                metadata,
              ],
            ),
          ),
          Wrap(children: [
            for (var option in setting.options) Text(option.name)
          ]),
        ]));
  }

  List<BottomSheetAction> _actions() {
    return <BottomSheetAction>[
      BottomSheetAction(
        title: Text('編輯設定'),
        leading: Icon(Icons.text_fields_sharp),
        onTap: (context) => Navigator.of(context).pushReplacementNamed(
          Routes.customerModal,
          arguments: setting,
        ),
      ),
      BottomSheetAction(
        title: Text('排序'),
        leading: Icon(Icons.reorder_sharp),
        onTap: (context) {
          Navigator.of(context)
              .pushReplacementNamed(Routes.customerSettingReorder);
        },
      ),
    ];
  }
}
