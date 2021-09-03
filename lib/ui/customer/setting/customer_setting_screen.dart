import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/objects/customer_object.dart';
import 'package:provider/provider.dart';

import '../../../routes.dart';

class CustomerSettingScreen extends StatelessWidget {
  const CustomerSettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final setting = context.watch<CustomerSetting>();
    final theme = Theme.of(context);
    final metadata = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text('此顧客設定的種類為「${customerSettingOptionModeString[setting.mode]!}」'),
      ],
    );
    final _navigateNewOption = () => Navigator.of(context).pushNamed(
          Routes.customerSettingOption,
          arguments: setting,
        );
    final body = setting.isEmpty
        ? EmptyBody(title: '尚未新增選項', onPressed: _navigateNewOption)
        : Wrap(children: [for (var option in setting.items) Text(option.name)]);

    return Scaffold(
        appBar: AppBar(
          title: Text(setting.name),
          leading: PopButton(),
          actions: [
            IconButton(
              onPressed: () => _showActions(context, setting),
              icon: Icon(KIcons.more),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateNewOption,
          tooltip: '新增顧客設定選項',
          child: Icon(KIcons.add),
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(kSpacing3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(setting.name, style: theme.textTheme.headline4),
                SizedBox(height: 4.0),
                metadata,
              ],
            ),
          ),
          body,
        ]));
  }

  void _showActions(BuildContext context, CustomerSetting setting) async {
    await BottomSheetActions.withDelete<_Action>(
      context,
      deleteValue: _Action.delete,
      warningContent: Text('你確定要刪除「${setting.name}」嗎\n此動作並不會影響使用此設定的點單。'),
      deleteCallback: setting.remove,
      actions: [
        BottomSheetAction<_Action>(
          title: Text('編輯資訊'),
          leading: Icon(Icons.text_fields_sharp),
          navigateRoute: Routes.customerModal,
          navigateArgument: setting,
        ),
        BottomSheetAction<_Action>(
          title: Text('排序'),
          leading: Icon(Icons.reorder_sharp),
          navigateRoute: Routes.customerSettingReorder,
          navigateArgument: setting,
        ),
      ],
    );
  }
}

enum _Action {
  edit,
  delete,
  reorder,
}
