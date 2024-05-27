import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/components/style/buttons.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/stock/replenishment.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class ReplenishmentPage extends StatelessWidget {
  const ReplenishmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    void goToCreate() => context.pushNamed(Routes.replenishmentNew);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.stockReplenishmentTitleList),
        leading: const PopButton(),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('replenisher.add'),
        onPressed: goToCreate,
        tooltip: S.stockReplenishmentTitleCreate,
        child: const Icon(KIcons.add),
      ),
      body: ListenableBuilder(
        listenable: Replenisher.instance,
        builder: (_, __) {
          if (Replenisher.instance.isEmpty) {
            return Center(
              child: EmptyBody(
                onPressed: goToCreate,
                content: S.stockReplenishmentEmptyBody,
              ),
            );
          }

          return buildList(context);
        },
      ),
    );
  }

  Widget buildList(BuildContext context) {
    void handler(Replenishment item, _Actions action) async {
      if (action == _Actions.apply) {
        final confirmed = await context.pushNamed<bool>(
          Routes.replenishmentApply,
          pathParameters: {'id': item.id},
        );

        if (confirmed == true && context.mounted && context.canPop()) {
          context.pop(true);
        }
      }
    }

    return SlidableItemList<Replenishment, _Actions>(
      delegate: SlidableItemDelegate(
        handleDelete: (item) => item.remove(),
        deleteValue: _Actions.delete,
        warningContentBuilder: (_, item) {
          return Text(S.dialogDeletionContent(item.name, ''));
        },
        items: Replenisher.instance.itemList,
        actionBuilder: (item) => [
          BottomSheetAction(
            title: Text(S.stockReplenishmentTitleUpdate),
            leading: const Icon(KIcons.edit),
            route: Routes.replenishmentModal,
            routePathParameters: {'id': item.id},
          ),
          BottomSheetAction(
            key: const Key('apply'),
            title: Text(S.stockReplenishmentApplyButton),
            leading: const Icon(Icons.check_circle_outline_sharp),
            returnValue: _Actions.apply,
          ),
        ],
        handleAction: handler,
        tileBuilder: (context, item, index, showActions) {
          return ListTile(
            key: Key('replenisher.${item.id}'),
            title: Text(item.name),
            subtitle: Text(S.stockReplenishmentMetaAffect(item.data.length)),
            onTap: () => handler(item, _Actions.apply),
            onLongPress: showActions,
            trailing: EntryMoreButton(onPressed: showActions),
          );
        },
      ),
    );
  }
}

enum _Actions {
  delete,
  apply,
}
