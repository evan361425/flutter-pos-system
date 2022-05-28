import 'package:flutter/material.dart';
import 'package:possystem/components/style/appbar_text_button.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/previews/customer_setting_previewer.dart';
import 'package:possystem/ui/exporter/previews/ingredient_previewer.dart';
import 'package:possystem/ui/exporter/previews/product_previewer.dart';
import 'package:possystem/ui/exporter/previews/quantity_previewer.dart';
import 'package:possystem/ui/exporter/previews/replenishment_previewer.dart';

abstract class PreviewerScreen<T extends Model> extends StatelessWidget {
  final List<FormattedItem> items;

  const PreviewerScreen({
    Key? key,
    required this.items,
  }) : super(key: key);

  static Future<bool?> navByTarget(
    BuildContext context,
    Formattable type,
    List<FormattedItem> items,
  ) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) {
          switch (type) {
            case Formattable.menu:
              return ProductPreviewer(items: items);
            case Formattable.customer:
              return CustomerSettingPreviewer(items: items);
            case Formattable.quantities:
              return QuantityPreviewer(items: items);
            case Formattable.stock:
              return IngredientPreviewer(items: items);
            case Formattable.replenisher:
              return ReplenishmentPreviewer(items: items);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.importPreviewerTitle),
        leading: const PopButton(icon: Icons.clear_sharp),
        actions: [
          AppbarTextButton(
            onPressed: () => Navigator.of(context).pop(items.isNotEmpty),
            child: Text(S.btnSave),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: getHeader(context),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: HintText(S.totalCount(items.length))),
          ),
          ...getDetails(context, items),
        ]),
      ),
    );
  }

  Iterable<Widget> getDetails(
    BuildContext context,
    Iterable<FormattedItem> items,
  ) sync* {
    for (final item in items) {
      yield item.hasError
          ? PreviewerErrorListTile(item)
          : getItem(context, item.item! as T);
    }
  }

  Widget getItem(BuildContext context, T item);

  Widget getHeader(BuildContext context) {
    return const Text('注意：匯入後將會把下面沒列到的資料移除，請確認是否執行！');
  }
}

class ImporterColumnStatus extends StatelessWidget {
  final String name;

  final String status;

  final FontWeight? fontWeight;

  const ImporterColumnStatus({
    Key? key,
    required this.name,
    required this.status,
    this.fontWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: name,
        style: DefaultTextStyle.of(context).style.copyWith(
              fontWeight: fontWeight,
            ),
        children: <TextSpan>[
          TextSpan(
            text: S.importerColumnStatus(status),
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}

class PreviewerErrorListTile extends StatelessWidget {
  final FormattedItem item;

  const PreviewerErrorListTile(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(item.hasError);
    final theme = Theme.of(context);
    final error = item.error!;

    return ListTile(
      title: Text(
        error.raw,
        style: const TextStyle(decoration: TextDecoration.lineThrough),
      ),
      subtitle: Text(
        error.message,
        style: TextStyle(color: theme.errorColor),
      ),
      tileColor: theme.listTileTheme.tileColor?.withAlpha(100),
    );
  }
}
