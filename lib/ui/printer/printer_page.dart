import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/components/style/buttons.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/route_buttons.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class PrinterPage extends StatelessWidget {
  const PrinterPage({super.key});

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
        routeName: Routes.printerCreate,
      );
    }

    return SlidableItemList(
      hintText: '', // disabling hint text
      leading: const Row(children: [
        Expanded(
          child: RouteElevatedIconButton(
            key: Key('printer.create'),
            route: Routes.printerCreate,
            icon: Icon(Icons.bluetooth_searching_outlined),
            label: '搜尋 & 新增',
          ),
        ),
      ]),
      delegate: SlidableItemDelegate(
        items: Printers.instance.items.sorted((a, b) => a.compareTo(b)),
        tileBuilder: (printer, _, actorBuilder) => _Tile(printer, actorBuilder),
        handleDelete: (printer) => printer.remove(),
        deleteValue: 0,
        warningContentBuilder: (_, printer) => Text(S.dialogDeletionContent(printer.name, '')),
        actionBuilder: (printer) => [
          BottomSheetAction(
            key: const Key('printer.update'),
            title: const Text('編輯設定'),
            leading: const Icon(KIcons.edit),
            route: Routes.printerUpdate,
            routePathParameters: {'id': printer.id},
          ),
          BottomSheetAction(
            key: const Key('printer.test'),
            title: const Text('測試列印'),
            leading: const Icon(Icons.print_outlined),
            route: Routes.printerTest,
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
    Widget subtitle;
    if (item.defaultReceiptPrinter) {
      subtitle = MetaBlock.withString(context, [
        '預設出單機',
        if (item.connected) '連接中',
      ])!;
    } else {
      subtitle = const HintText('未指定用途');
    }

    return ListTile(
      key: Key('printer.${item.id}'),
      title: Text(item.name),
      subtitle: subtitle,
      selected: item.connected,
      trailing: EntryMoreButton(onPressed: actor),
      onLongPress: actor,
      onTap: () => context.pushNamed(
        Routes.printerConnect,
        pathParameters: {'id': item.id},
      ),
    );
  }
}
