import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/components/style/snackbar.dart';
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

  List<BottomSheetAction> get _actions {
    return <BottomSheetAction>[
      BottomSheetAction(
        title: Text(tt('delete')),
        leading: Icon(KIcons.delete),
        onTap: (context) => Navigator.of(context).pop(_Actions.delete),
      ),
    ];
  }

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
            Wrap(spacing: kSpacing1, children: [
              for (final item in setting.items)
                OutlinedText(
                  item.name,
                  colored: item.isDefault,
                )
            ]),
            Row(children: [
              Spacer(),
              _actionButton(context),
              SizedBox(width: kSpacing1),
              _navigateSettingButton(context),
            ]),
          ],
        ),
      ]),
    );
  }

  Widget _actionButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        final result = await showCircularBottomSheet<_Actions>(
          context,
          actions: _actions,
        );

        if (result == _Actions.delete) {
          return _handleDelete(context);
        }
      },
      child: Text('操作'),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => DeleteDialog(
        content: Text('你確定要刪除「${setting.name}」\n此動作並不會影響使用此設定的點單。'),
      ),
    );

    if (isConfirmed != true) {
      return;
    }

    await setting.remove();

    showSuccessSnackbar(context, tt('success'));
  }

  Widget _navigateSettingButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.of(context).pushNamed(
        Routes.customerSetting,
        arguments: setting,
      ),
      child: Text('查看細節'),
    );
  }
}

enum _Actions {
  delete,
}
