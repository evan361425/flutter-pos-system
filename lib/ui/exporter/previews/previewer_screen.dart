import 'package:flutter/material.dart';
import 'package:possystem/components/style/appbar_text_button.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/previews/product_previewer.dart';

abstract class PreviewerScreen extends StatelessWidget {
  final List<FormattedItem> items;

  const PreviewerScreen({
    Key? key,
    required this.items,
  }) : super(key: key);

  static Future<bool?> navByTarget(
    BuildContext context,
    Repository target,
    List<FormattedItem> items,
  ) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) {
          if (target is Menu) {
            return ProductPreviewer(items: items);
          }

          return _DefaultPreviewScreen(items: items);
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
          ...getDetails(context, items),
        ]),
      ),
    );
  }

  Iterable<Widget> getDetails(
    BuildContext context,
    Iterable<FormattedItem> items,
  );

  Widget countHint(int count) {
    return Center(child: HintText(S.totalCount(count)));
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
      title: Text(error.raw),
      subtitle: Text(
        error.message,
        style: TextStyle(color: theme.errorColor),
      ),
      tileColor: theme.listTileTheme.tileColor?.withAlpha(100),
    );
  }
}

class _DefaultPreviewScreen extends PreviewerScreen {
  const _DefaultPreviewScreen({
    required List<FormattedItem> items,
  }) : super(items: items);

  @override
  Iterable<Widget> getDetails(
    BuildContext context,
    Iterable<FormattedItem> items,
  ) sync* {
    for (final item in items) {
      assert(!item.hasError);
      yield ListTile(title: Text(item.item!.name));
    }
  }
}
