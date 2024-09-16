import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/responsive_dialog.dart';
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
    return ResponsiveDialog(
      title: Text(S.stockReplenishmentTitleList),
      scrollable: false,
      content: ListenableBuilder(
        listenable: Replenisher.instance,
        builder: (context, title) {
          handleCreate() => context.pushNamed(Routes.stockReplCreate);
          if (Replenisher.instance.isEmpty) {
            return Center(
              child: EmptyBody(
                onPressed: handleCreate,
                content: S.stockReplenishmentEmptyBody,
              ),
            );
          }

          return buildList(
            (Replenishment a, ReplenishActions b) => handleActions(context, a, b),
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  key: const Key('replenisher.add'),
                  onPressed: handleCreate,
                  label: Text(S.stockReplenishmentTitleCreate),
                  icon: const Icon(KIcons.add),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }

  Widget buildList(
    void Function(Replenishment a, ReplenishActions b) actionHandler,
    Widget leading,
  ) {
    return SlidableItemList<Replenishment, ReplenishActions>(
      leading: leading,
      delegate: SlidableItemDelegate(
        handleDelete: (item) => item.remove(),
        deleteValue: ReplenishActions.delete,
        warningContentBuilder: (_, item) {
          return Text(S.dialogDeletionContent(item.name, ''));
        },
        items: Replenisher.instance.itemList,
        actionBuilder: (item) => [
          BottomSheetAction(
            title: Text(S.stockReplenishmentTitleUpdate),
            leading: const Icon(KIcons.edit),
            route: Routes.stockReplUpdate,
            routePathParameters: {'id': item.id},
          ),
          BottomSheetAction(
            title: Text(S.stockReplenishmentApplyPreview),
            leading: const Icon(Icons.check_outlined),
            returnValue: ReplenishActions.preview,
          ),
        ],
        handleAction: actionHandler,
        tileBuilder: (item, index, actorBuilder) => _Tile(
          item: item,
          actorBuilder: actorBuilder,
          onTap: () => actionHandler(item, ReplenishActions.preview),
        ),
      ),
    );
  }

  void handleActions(BuildContext context, Replenishment item, ReplenishActions action) async {
    if (action == ReplenishActions.preview) {
      final confirmed = await context.pushNamed<bool>(
        Routes.stockReplPreview,
        pathParameters: {'id': item.id},
      );

      if (confirmed == true && context.mounted) {
        PopButton.safePop(context, value: true);
      }
    }
  }
}

class _Tile extends StatelessWidget {
  final Replenishment item;
  final ActorBuilder actorBuilder;
  final VoidCallback onTap;

  const _Tile({
    required this.item,
    required this.actorBuilder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final actor = actorBuilder(context);
    return ListTile(
      key: Key('replenisher.${item.id}'),
      title: Text(item.name),
      subtitle: Text(S.stockReplenishmentMetaAffect(item.data.length)),
      onTap: onTap,
      onLongPress: actor,
      trailing: EntryMoreButton(onPressed: actor),
    );
  }
}

enum ReplenishActions {
  delete,
  preview,
}
