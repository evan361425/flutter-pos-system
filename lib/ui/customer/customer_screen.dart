import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

import 'widgets/customer_setting_list.dart';

class CustomerScreen extends StatelessWidget {
  const CustomerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<CustomerSettings>();

    goAddSetting() => Navigator.of(context).pushNamed(Routes.customerModal);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.customerSettingTitle),
        leading: const PopButton(),
        actions: [
          IconButton(
            key: const Key('customer_settings.action'),
            onPressed: () => _showActions(context),
            icon: const Icon(KIcons.more),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: goAddSetting,
        tooltip: S.customerSettingCreate,
        child: const Icon(KIcons.add),
      ),
      body: settings.isEmpty
          ? Center(
              child: EmptyBody(
              onPressed: goAddSetting,
              tooltip: '顧客設定可以幫助我們統計都是哪些人來買我們的產品\n例如：\n20-30歲、外帶、上班族。',
            ))
          : CustomerSettingList(settings.itemList),
    );
  }

  void _showActions(BuildContext context) async {
    await showCircularBottomSheet(context, actions: [
      BottomSheetAction(
        title: Text(S.customerSettingReorder),
        leading: const Icon(Icons.reorder_sharp),
        navigateRoute: Routes.customerReorder,
      ),
    ]);
  }
}
