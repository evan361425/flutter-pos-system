import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/models/order_attribute_value_widget.dart';
import 'package:possystem/components/style/buttons.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/components/style/slide_to_delete.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class OrderAttributeTile extends StatelessWidget {
  final OrderAttribute attr;

  const OrderAttributeTile({super.key, required this.attr});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: attr,
      builder: (context, child) => _buildTile(context),
    );
  }

  Widget _buildTile(BuildContext context) {
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
        _buildActions(context),
        const SizedBox(height: kInternalLargeSpacing),
        for (final item in attr.itemList) _OptionTile(item),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(children: [
      const SizedBox(width: kHorizontalSpacing),
      Expanded(
        child: ElevatedButton.icon(
          key: Key('order_attributes.${attr.id}.add'),
          onPressed: () => context.pushNamed(
            Routes.orderAttrCreate,
            queryParameters: {'id': attr.id},
          ),
          label: Text(S.orderAttributeOptionTitleCreate),
          icon: const Icon(KIcons.add),
        ),
      ),
      EntryMoreButton(
        key: Key('order_attributes.${attr.id}.more'),
        onPressed: _showActions,
      ),
      const SizedBox(width: kHorizontalSpacing),
    ]);
  }

  void _showActions(BuildContext context) async {
    await BottomSheetActions.withDelete<int>(
      context,
      deleteValue: 0,
      actions: <BottomSheetAction<int>>[
        BottomSheetAction(
          title: Text(S.orderAttributeTitleUpdate),
          leading: const Icon(KIcons.modal),
          route: Routes.orderAttrUpdate,
          routePathParameters: {'id': attr.id},
        ),
        BottomSheetAction(
          title: Text(S.orderAttributeOptionTitleReorder),
          leading: const Icon(KIcons.reorder),
          route: Routes.orderAttrReorderOption,
          routePathParameters: {'id': attr.id},
        ),
      ],
      warningContent: Text(S.dialogDeletionContent(attr.name, '')),
      deleteCallback: () => attr.remove(),
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
          Routes.orderAttrUpdate,
          pathParameters: {'id': option.attribute.id},
          queryParameters: {'oid': option.id},
        ),
      ),
    );
  }

  Future<void> _remove() => option.remove();
}
