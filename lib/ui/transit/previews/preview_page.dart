import 'package:flutter/material.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';

import 'ingredient_preview_page.dart';
import 'order_attribute_preview_page.dart';
import 'product_preview_page.dart';
import 'quantity_preview_page.dart';
import 'replenishment_preview_page.dart';

typedef PreviewFormatter = List<FormattedItem>? Function(FormattableModel);
typedef PreviewOnDone = void Function(BuildContext);

abstract class PreviewPage<T extends Model> extends StatelessWidget {
  final FormattableModel able;
  final List<FormattedItem> items;
  final Map<FormattableModel, ValueNotifier<bool>>? progress;

  const PreviewPage({
    super.key,
    required this.able,
    required this.items,
    this.progress,
  });

  static Widget buildTabBarView({
    required List<FormattableModel> ables,
    required PreviewFormatter formatter,
  }) {
    Widget builder(FormattableModel able, Map<FormattableModel, ValueNotifier<bool>>? progress) {
      final items = formatter(able);
      if (items == null) {
        progress?[able]?.value = true;
        return HintText(S.transitImportErrorPreviewNotFound(able.l10nName));
      }

      switch (able) {
        case FormattableModel.menu:
          return ProductPreviewPage(able: able, items: items, progress: progress);
        case FormattableModel.orderAttr:
          return OrderAttributePreviewPage(able: able, items: items, progress: progress);
        case FormattableModel.quantities:
          return QuantityPreviewPage(able: able, items: items, progress: progress);
        case FormattableModel.stock:
          return IngredientPreviewPage(able: able, items: items, progress: progress);
        case FormattableModel.replenisher:
          return ReplenishmentPreviewPage(able: able, items: items, progress: progress);
      }
    }

    if (ables.length == 1) {
      return builder(ables.first, null);
    }

    final progress = <FormattableModel, ValueNotifier<bool>>{
      for (final able in ables) able: ValueNotifier(false),
    };
    return DefaultTabController(
      length: ables.length,
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        TabBar(tabs: [
          for (final able in ables)
            Tab(
              child: Text(able.l10nName, softWrap: true),
            ),
        ]),
        TabBarView(children: [
          for (final able in ables) builder(able, progress),
        ]),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [_buildAction(context)]),
      const SizedBox(height: kInternalSpacing),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: kHorizontalSpacing),
        child: buildHeader(context),
      ),
      const Divider(),
      Padding(
        padding: const EdgeInsets.fromLTRB(kHorizontalSpacing, 0, kHorizontalSpacing, kInternalSpacing),
        child: Center(child: HintText(S.totalCount(items.length))),
      ),
      ...buildDetails(context, items),
    ]);
  }

  Widget _buildAction(BuildContext context) {
    if (progress == null) {
      return _buildConfirmedButton(context);
    }

    return ValueListenableBuilder<bool>(
      valueListenable: progress![able]!,
      builder: (context, value, child) {
        final notReady = progress!.values.where((e) => !e.value).length;
        if (notReady == 0) {
          return _buildConfirmedButton(context);
        }

        return Column(
          children: [
            Row(children: [
              Checkbox.adaptive(value: value, onChanged: (value) => progress![able]!.value = !value!),
              Text(S.transitImportPreviewConfirmVerify),
            ]),
            HintText(S.transitImportPreviewConfirmHint(notReady)),
          ],
        );
      },
    );
  }

  Widget _buildConfirmedButton(BuildContext context) {
    return FilledButton(
      onPressed: () async {
        final futures = (progress?.keys.toList() ?? [able]).map((e) => e.toRepository().commitStaged());
        final result = await showSnackbarWhenFutureError(
          Future.wait(futures),
          'transit_import_failed',
          context: context,
        );

        if (result != null && context.mounted) {
          showSnackBar(S.transitImportSuccess, context: context);
        }
      },
      child: Text(S.transitImportPreviewConfirmBtn),
    );
  }

  Iterable<Widget> buildDetails(
    BuildContext context,
    Iterable<FormattedItem> items,
  ) sync* {
    for (final item in items) {
      yield item.hasError ? PreviewErrorListTile(item) : buildItem(context, item.item! as T);
    }
  }

  Widget buildItem(BuildContext context, T item);

  Widget buildHeader(BuildContext context) {
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
