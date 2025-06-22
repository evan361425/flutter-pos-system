import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
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

class PreviewPageWrapper extends StatefulWidget {
  final List<FormattableModel> ables;
  final PreviewFormatter formatter;

  const PreviewPageWrapper({
    super.key,
    required this.ables,
    required this.formatter,
  });

  @override
  State<PreviewPageWrapper> createState() => _PreviewPageWrapperState();
}

class _PreviewPageWrapperState extends State<PreviewPageWrapper> {
  Map<FormattableModel, ValueNotifier<bool>>? progress;

  @override
  Widget build(BuildContext context) {
    if (widget.ables.length == 1) {
      return _buildPage(widget.ables.first);
    }

    return DefaultTabController(
      length: widget.ables.length,
      child: Column(children: <Widget>[
        TabBar.secondary(isScrollable: true, tabs: [
          for (final able in widget.ables)
            Tab(
              child: Text(able.l10nName, softWrap: true),
            ),
        ]),
        Expanded(
          child: TabBarView(children: [
            for (final able in widget.ables) _buildPage(able),
          ]),
        ),
      ]),
    );
  }

  @override
  void initState() {
    if (widget.ables.length > 1) {
      progress = <FormattableModel, ValueNotifier<bool>>{
        for (final able in widget.ables) able: ValueNotifier(false),
      };
    }
    super.initState();
  }

  Widget _buildPage(FormattableModel able) {
    final items = widget.formatter(able);
    if (items == null) {
      // missing this sheet data is still able to import other sheets
      progress?[able]?.value = true;
      return Center(child: HintText(S.transitImportErrorPreviewNotFound(able.l10nName)));
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
}

abstract class PreviewPage<T extends Model> extends StatelessWidget {
  final FormattableModel able;
  final List<FormattedItem> items;
  final Map<FormattableModel, ValueNotifier<bool>>? progress;
  final ScrollPhysics? physics;

  const PreviewPage({
    super.key,
    required this.able,
    required this.items,
    this.progress,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      const SizedBox(height: 4.0),
      _buildAction(context),
      const SizedBox(height: kInternalSpacing),
      Center(child: HintText(S.totalCount(items.length))),
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

        return CheckboxListTile(
          value: value,
          onChanged: (value) => progress![able]!.value = value!,
          title: Text(S.transitImportPreviewConfirmVerify),
          subtitle: Text(S.transitImportPreviewConfirmHint(notReady)),
        );
      },
    );
  }

  Widget _buildConfirmedButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kHorizontalSpacing),
      child: Align(
        alignment: Alignment.centerRight,
        child: FilledButton(
          key: const Key('transit.import.confirm'),
          child: Text(S.transitImportPreviewConfirmBtn),
          onPressed: () async {
            final confirmed = await ConfirmDialog.show(
              context,
              title: S.transitImportPreviewConfirmTitle,
              content: confirmedMessage,
            );
            if (!confirmed) {
              return;
            }

            final futures = (progress?.keys.toList() ?? [able]).map((e) => e.toRepository().commitStaged());
            final result = await showSnackbarWhenFutureError(
              Future.wait(futures),
              'transit_import_model',
              // ignore: use_build_context_synchronously
              context: context,
            );

            if (result != null && context.mounted) {
              showSnackBar(S.transitImportSuccess, context: context);
            }
          },
        ),
      ),
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

  String get confirmedMessage => S.transitImportPreviewConfirmContent;
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

class SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
