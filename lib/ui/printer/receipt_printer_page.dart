import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/components/style/buttons.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/models/printer/printer.dart';
import 'package:possystem/models/repository/printers.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class ReceiptPrinterPage extends StatelessWidget {
  const ReceiptPrinterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      key: const Key('printers_page'),
      listenable: Printers.instance,
      builder: (context, child) => _buildBody(),
    );
  }

  Widget _buildBody() {
    if (Printers.instance.isEmpty) {
      return const EmptyBody(
        content: '透過藍牙連接出單機，以列印訂單資訊',
        routeName: Routes.printersCreate,
      );
    }

    return SlidableItemList(
      hintText: '',
      leading: Row(children: [
        Expanded(
          child: RouteElevatedIconButton(
            key: const Key('quantity.add'),
            route: Routes.quantityCreate,
            label: S.stockQuantityTitleCreate,
            icon: const Icon(KIcons.add),
          ),
        ),
      ]),
      delegate: SlidableItemDelegate(
        // descending order
        items: Printers.instance.items.sorted((a, b) => b.usage.index.compareTo(a.usage.index)),
        tileBuilder: (printer, _, actorBuilder) => _Tile(printer, actorBuilder),
        handleDelete: (printer) => printer.remove(),
        deleteValue: 0,
        warningContentBuilder: (_, printer) => Text(S.dialogDeletionContent(printer.name, '')),
        actionBuilder: (printer) => [
          BottomSheetAction(
            key: const Key('btn.usage'),
            title: const Text('選擇用途'),
            leading: const Icon(Icons.question_mark_outlined),
            route: Routes.printersUsage,
            routePathParameters: {'id': printer.id},
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final Printer item;
  final ActorBuilder actorBuilder;

  const _Tile(this.item, this.actorBuilder);

  @override
  Widget build(BuildContext context) {
    final actor = actorBuilder(context);
    return ListTile(
      key: Key('printers.${item.id}'),
      title: Text(item.name),
      subtitle: item.usage == PrinterUsage.unassigned ? const HintText('未指定用途') : const Text('預設出單機'),
      trailing: EntryMoreButton(onPressed: actor),
      onLongPress: actor,
      onTap: () => context.pushNamed(
        Routes.printersUsage,
        pathParameters: {'id': item.id},
      ),
    );
  }
}
