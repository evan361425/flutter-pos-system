import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/models/order_attribute_value_widget.dart';
import 'package:possystem/components/style/buttons.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/components/style/slide_to_delete.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

class OrderAttributeList extends StatelessWidget {
  final List<OrderAttribute> attributes;

  final Widget tailing;

  const OrderAttributeList({super.key, required this.attributes, required this.tailing});

  @override
  Widget build(BuildContext context) {
    return ListView(children: <Widget>[
      const SizedBox(height: 8.0),
      Center(child: HintText(S.totalCount(attributes.length))),
      const SizedBox(height: 8.0),
      for (final attribute in attributes)
        ChangeNotifierProvider<OrderAttribute>.value(
          value: attribute,
          child: const _OrderAttributeCard(),
        ),
      tailing,
      // Floating action button offset
      const SizedBox(height: 72.0),
    ]);
  }
}

class _OrderAttributeCard extends StatelessWidget {
  const _OrderAttributeCard();

  @override
  Widget build(BuildContext context) {
    final attr = context.watch<OrderAttribute>();
    final key = 'order_attributes.${attr.id}';
    final theme = Theme.of(context);
    final subtitle = RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(text: S.orderAttributeMetaMode(S.orderAttributeModeName(attr.mode.name))),
          MetaBlock.span(),
          attr.defaultOption?.name != null
              ? TextSpan(text: S.orderAttributeMetaDefault(attr.defaultOption!.name))
              : TextSpan(text: S.orderAttributeMetaDefault(''), children: [
                  TextSpan(
                    text: S.orderAttributeMetaNoDefault,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                  ),
                ]),
        ],
        // disable parent text style
        style: theme.textTheme.bodyMedium,
      ),
    );

    return ExpansionTile(
      key: Key(key),
      title: Text(attr.name),
      subtitle: subtitle,
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        buildActions(context, attr),
        const SizedBox(height: 12.0),
        for (final item in attr.itemList) _OptionTile(item),
      ],
    );
  }

  void showActions(BuildContext context, OrderAttribute attr) {
    BottomSheetActions.withDelete<int>(
      context,
      deleteValue: 0,
      actions: <BottomSheetAction<int>>[
        BottomSheetAction(
          title: Text(S.orderAttributeTitleUpdate),
          leading: const Icon(KIcons.modal),
          route: Routes.orderAttrModal,
          routePathParameters: {'id': attr.id},
        ),
        BottomSheetAction(
          title: Text(S.orderAttributeOptionTitleReorder),
          leading: const Icon(KIcons.reorder),
          route: Routes.orderAttrOptionReorder,
          routePathParameters: {'id': attr.id},
        ),
      ],
      warningContent: Text(S.dialogDeletionContent(attr.name, '')),
      deleteCallback: () => attr.remove(),
    );
  }

  Widget buildActions(BuildContext context, OrderAttribute attr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () => context.pushNamed(
            Routes.orderAttrNew,
            queryParameters: {'id': attr.id},
          ),
          label: Text(S.orderAttributeOptionTitleCreate),
          icon: const Icon(KIcons.add),
        ),
        const SizedBox(width: 8.0),
        EntryMoreButton(
          key: Key('$key.more'),
          onPressed: () => showActions(context, attr),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final OrderAttributeOption option;

  const _OptionTile(this.option);

  @override
  Widget build(BuildContext context) {
    return SlideToDelete(
      item: option,
      deleteCallback: _remove,
      warningContent: Text(S.dialogDeletionContent(option.name, '')),
      child: ListTile(
        key: Key('order_attributes.${option.repository.id}.${option.id}'),
        title: Text(option.name),
        subtitle: OrderAttributeValueWidget.build(option.mode, option.modeValue),
        trailing: option.isDefault ? OutlinedText(S.orderAttributeOptionMetaDefault) : null,
        onLongPress: () => BottomSheetActions.withDelete<int>(
          context,
          deleteValue: 0,
          warningContent: Text(S.dialogDeletionContent(option.name, '')),
          deleteCallback: _remove,
        ),
        onTap: () => context.pushNamed(
          Routes.orderAttrModal,
          pathParameters: {'id': option.attribute.id},
          queryParameters: {'oid': option.id},
        ),
      ),
    );
  }

  Future<void> _remove() => option.remove();
}
