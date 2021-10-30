import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/customer/widgets/customer_setting_list.dart';
import 'package:provider/provider.dart';

class CustomerScreen extends StatelessWidget {
  const CustomerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<CustomerSettings>();

    final goAddSetting =
        () => Navigator.of(context).pushNamed(Routes.customerModal);

    return Scaffold(
        appBar: AppBar(
          title: Text('顧客設定'),
          leading: PopButton(),
          actions: [
            IconButton(
              key: Key('customer_settings.action'),
              onPressed: () => _showActions(context),
              icon: Icon(KIcons.more),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: goAddSetting,
          tooltip: '新增顧客設定',
          child: Icon(KIcons.add),
        ),
        body: settings.isEmpty
            ? Center(child: EmptyBody(onPressed: goAddSetting))
            : CustomerSettingList(settings.itemList));
  }

  void _showActions(BuildContext context) async {
    await showCircularBottomSheet(context, actions: [
      BottomSheetAction(
        title: Text('排序'),
        leading: Icon(Icons.reorder_sharp),
        navigateRoute: Routes.customerReorder,
      ),
    ]);
  }
}
