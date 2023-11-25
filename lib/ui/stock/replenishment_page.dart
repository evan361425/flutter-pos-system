import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/more_button.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/stock/replenishment.dart';
import 'package:possystem/routes.dart';
import 'package:provider/provider.dart';

import 'package:possystem/translator.dart';

class ReplenishmentPage extends StatefulWidget {
  const ReplenishmentPage({Key? key}) : super(key: key);

  @override
  State<ReplenishmentPage> createState() => _ReplenishmentPageState();
}

class _ReplenishmentPageState extends State<ReplenishmentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.stockReplenishmentTitle),
        leading: const PopButton(),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('replenisher.add'),
        onPressed: goToCreate,
        tooltip: S.stockReplenishmentCreate,
        child: const Icon(KIcons.add),
      ),
      body: body,
    );
  }

  @override
  void didChangeDependencies() {
    context.watch<Replenisher>();
    super.didChangeDependencies();
  }

  Widget get body {
    if (Replenisher.instance.isEmpty) {
      return Center(
          child: EmptyBody(
        onPressed: goToCreate,
        helperText: '採購可以幫你快速調整成分的庫存',
      ));
    }

    return SlidableItemList<Replenishment, _Actions>(
      withFAB: true,
      delegate: SlidableItemDelegate(
        handleDelete: (item) => item.remove(),
        deleteValue: _Actions.delete,
        warningContentBuilder: (_, item) {
          return Text(S.dialogDeletionContent(item.name, ''));
        },
        items: Replenisher.instance.itemList,
        actionBuilder: (item) => [
          BottomSheetAction(
            title: const Text('編輯採購'),
            leading: const Icon(KIcons.edit),
            route: Routes.replenishmentModal,
            routePathParameters: {'id': item.id},
          ),
          const BottomSheetAction(
            key: Key('apply'),
            title: Text('套用採購'),
            leading: Icon(Icons.check_circle_outline_sharp),
            returnValue: _Actions.apply,
          ),
        ],
        handleAction: handleAction,
        tileBuilder: (context, item, index, showActions) => ListTile(
          key: Key('replenisher.${item.id}'),
          title: Text(item.name),
          subtitle: Text(S.stockReplenishmentSubtitle(item.data.length)),
          onTap: () => handleAction(item, _Actions.apply),
          onLongPress: showActions,
          trailing: EntryMoreButton(onPressed: showActions),
        ),
      ),
    );
  }

  void goToCreate() {
    context.pushNamed(Routes.replenishmentNew);
  }

  void handleAction(Replenishment item, _Actions action) {
    if (action == _Actions.apply) {
      handleApply(item);
    }
  }

  Future<void> handleApply(Replenishment item) async {
    final confirmed = await context.pushNamed<bool>(
      Routes.replenishmentApply,
      pathParameters: {'id': item.id},
    );

    if (context.mounted && confirmed == true && context.canPop()) {
      context.pop(true);
    }
  }
}

enum _Actions {
  delete,
  apply,
}
