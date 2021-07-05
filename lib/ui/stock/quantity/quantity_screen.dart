import 'package:flutter/material.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/quantity_repo.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/stock/quantity/widgets/quantity_list.dart';
import 'package:provider/provider.dart';

class QuantityScreen extends StatelessWidget {
  const QuantityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quantities = context.watch<QuantityRepo>();

    return Scaffold(
      appBar: AppBar(
        title: Text('份量'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.of(context).pushNamed(Routes.stockQuantityModal),
        tooltip: '新增份量',
        child: Icon(KIcons.add),
      ),
      body: quantities.isReady ? _body(quantities) : CircularLoading(),
    );
  }

  Widget _body(QuantityRepo quantities) {
    if (quantities.isEmpty) return Center(child: EmptyBody('quantity.empty'));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpacing2),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // TODO: search bar
            QuantityList(quantities: quantities.itemList),
          ],
        ),
      ),
    );
  }
}
