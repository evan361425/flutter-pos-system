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
  final List<FormattableModel> models;
  final PreviewFormatter formatter;

  const PreviewPageWrapper({
    super.key,
    required this.models,
    required this.formatter,
  });

  @override
  State<PreviewPageWrapper> createState() => _PreviewPageWrapperState();
}

class _PreviewPageWrapperState extends State<PreviewPageWrapper> {
  Map<FormattableModel, ValueNotifier<bool>>? progress;

  @override
  Widget build(BuildContext context) {
    if (widget.models.length == 1) {
      return _buildPage(widget.models.first);
    }

    return DefaultTabController(
      length: widget.models.length,
      child: Column(children: <Widget>[
        TabBar.secondary(isScrollable: true, tabs: [
          for (final model in widget.models)
            Tab(
              child: Text(model.l10nName, softWrap: true),
            ),
        ]),
        Expanded(
          child: TabBarView(children: [
            for (final model in widget.models) _buildPage(model),
          ]),
        ),
      ]),
    );
  }

  @override
  void initState() {
    if (widget.models.length > 1) {
      progress = <FormattableModel, ValueNotifier<bool>>{
        for (final model in widget.models) model: ValueNotifier(false),
      };
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    FormattableModel.abort();
  }

  Widget _buildPage(FormattableModel model) {
    final items = widget.formatter(model);
    if (items == null || items.isEmpty) {
      // missing this sheet data is still able to import other sheets
      progress?[model]?.value = true;
      return Center(child: HintText(S.transitImportErrorPreviewNotFound(model.l10nName)));
    }

    return switch (model) {
      FormattableModel.menu => ProductPreviewPage(model: model, items: items, progress: progress),
      FormattableModel.orderAttr => OrderAttributePreviewPage(model: model, items: items, progress: progress),
      FormattableModel.quantities => QuantityPreviewPage(model: model, items: items, progress: progress),
      FormattableModel.stock => IngredientPreviewPage(model: model, items: items, progress: progress),
      FormattableModel.replenisher => ReplenishmentPreviewPage(model: model, items: items, progress: progress),
    };
  }
}

abstract class PreviewPage<T extends Model> extends StatelessWidget {
  final FormattableModel model;
  final List<FormattedItem> items;
  final Map<FormattableModel, ValueNotifier<bool>>? progress;
  final ScrollPhysics? physics;

  const PreviewPage({
    super.key,
    required this.model,
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
      valueListenable: progress![model]!,
      builder: (context, value, child) {
        final notReady = progress!.values.where((e) => !e.value).length;
        if (notReady == 0) {
          return _buildConfirmedButton(context);
        }

        return CheckboxListTile(
          value: value,
          onChanged: (value) => progress![model]!.value = value!,
          title: Text(S.transitImportPreviewConfirmVerify),
          subtitle: Text(S.transitImportPreviewConfirmHint(notReady)),
        );
      },
    );
  }

  Widget _buildConfirmedButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kHorizontalSpacing),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        FilledButton(
          key: const Key('transit.import.confirm'),
          child: Text(S.transitImportPreviewConfirmBtn),
          onPressed: () async {
            final confirmed = await ConfirmDialog.show(
              context,
              title: S.transitImportPreviewConfirmTitle,
            );
            if (!confirmed) {
              return;
            }

            final result = await showSnackbarWhenFutureError(
              Future.forEach(progress?.keys.toList() ?? [model], (e) => e.toRepository().commitStaged())
                  .then((_) => true),
              'transit_import_model',
              // ignore: use_build_context_synchronously
              context: context,
            );

            if (result != null && context.mounted) {
              showSnackBar(S.transitImportSuccess, context: context);
            }
          },
        ),
        Text(helpMessage),
      ]),
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

  String get helpMessage => S.transitImportPreviewConfirmContent;
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
        style: DefaultTextStyle.of(context).style.copyWith(fontWeight: fontWeight),
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
