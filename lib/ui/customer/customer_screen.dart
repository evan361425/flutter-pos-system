import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/customers.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/customer/widgets/customer_setting_card.dart';
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
              onPressed: () => showCircularBottomSheet(
                context,
                actions: _actions(),
              ),
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
            : _body(settings));
  }

  List<BottomSheetAction> _actions() {
    return <BottomSheetAction>[
      BottomSheetAction(
        title: Text('排序'),
        leading: Icon(Icons.reorder_sharp),
        onTap: (context) {
          Navigator.of(context).pushReplacementNamed(Routes.customerReorder);
        },
      ),
    ];
  }

  Widget _body(CustomerSettings settings) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          for (final setting in settings.itemList)
            CustomerSettingCard(setting: setting)
        ],
      ),
    );
  }
}
