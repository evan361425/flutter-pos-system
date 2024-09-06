import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/responsive_dialog.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/translator.dart';

import 'ingredient_preview_page.dart';
import 'order_attribute_preview_page.dart';
import 'product_preview_page.dart';
import 'quantity_preview_page.dart';
import 'replenishment_preview_page.dart';

abstract class PreviewPage<T extends Model> extends StatelessWidget {
  final List<FormattedItem> items;

  const PreviewPage({
    super.key,
    required this.items,
  });

  static Future<bool?> show(
    BuildContext context,
    Formattable able,
    List<FormattedItem> items,
  ) {
    return showAdaptiveDialog<bool?>(
      context: context,
      builder: (context) {
        switch (able) {
          case Formattable.menu:
            return ProductPreviewPage(items: items);
          case Formattable.orderAttr:
            return OrderAttributePreviewPage(items: items);
          case Formattable.quantities:
            return QuantityPreviewPage(items: items);
          case Formattable.stock:
            return IngredientPreviewPage(items: items);
          case Formattable.replenisher:
            return ReplenishmentPreviewPage(items: items);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialog(
      title: Text(S.transitImportPreviewTitle),
      action: TextButton(
        onPressed: () {
          Navigator.of(context).pop(items.isNotEmpty);
        },
        child: Text(MaterialLocalizations.of(context).saveButtonLabel),
      ),
      content: Column(children: [
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
    );
  }

  Iterable<Widget> getDetails(
    BuildContext context,
    Iterable<FormattedItem> items,
  ) sync* {
    for (final item in items) {
      yield item.hasError ? PreviewErrorListTile(item) : getItem(context, item.item! as T);
    }
  }

  Widget getItem(BuildContext context, T item);

  Widget getHeader(BuildContext context) {
    return Text(S.transitImportPreviewHeader);
  }
}

class ImporterColumnStatus extends StatelessWidget {
  final String name;

  final String status;

  final FontWeight? fontWeight;

  const ImporterColumnStatus({
    super.key,
    required this.name,
    required this.status,
    this.fontWeight,
  });

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
            text: S.transitImportColumnStatus(status),
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

class PreviewErrorListTile extends StatelessWidget {
  final FormattedItem item;

  const PreviewErrorListTile(this.item, {super.key});

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
        style: TextStyle(color: theme.colorScheme.error),
      ),
      tileColor: theme.listTileTheme.tileColor?.withAlpha(100),
    );
  }
}
