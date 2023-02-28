import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/models/order_attribute_value_widget.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

class OrderAttributeList extends StatelessWidget {
  final List<OrderAttribute> attributes;

  const OrderAttributeList(this.attributes, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(kSpacing1),
            child: HintText(S.totalCount(attributes.length)),
          ),
          for (final attribute in attributes)
            ChangeNotifierProvider<OrderAttribute>.value(
              value: attribute,
              child: const _OrderAttributeCard(),
            )
        ],
      ),
    );
  }
}

class _OrderAttributeCard extends StatelessWidget {
  const _OrderAttributeCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final attr = context.watch<OrderAttribute>();
    final mode = S.orderAttributeModeNames(attr.mode.name);
    final defaultName =
        attr.defaultOption?.name ?? S.orderAttributeMetaNoDefault;
    final key = 'order_attributes.${attr.id}';

    return ExpansionTile(
      key: Key(key),
      title: Text(attr.name),
      subtitle: MetaBlock.withString(context, [
        S.orderAttributeMetaMode(mode),
        S.orderAttributeMetaDefault(defaultName),
      ]),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ListTile(
          key: Key('$key.add'),
          leading: const CircleAvatar(child: Icon(KIcons.add)),
          title: Text(S.orderAttributeOptionCreate),
          onTap: () => Navigator.of(context).pushNamed(
            Routes.orderAttrOption,
            arguments: attr,
          ),
          trailing: IconButton(
            key: Key('$key.more'),
            onPressed: () => showActions(context, attr),
            enableFeedback: true,
            icon: const Icon(KIcons.more),
          ),
        ),
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
          title: Text(S.orderAttributeUpdate),
          leading: const Icon(Icons.text_fields_sharp),
          navigateRoute: Routes.orderAttrModal,
          navigateArgument: attr,
        ),
        BottomSheetAction(
          title: Text(S.orderAttributeOptionReorder),
          leading: const Icon(Icons.reorder_sharp),
          navigateRoute: Routes.orderAttrOptionReorder,
          navigateArgument: attr,
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
    return ListTile(
      key: Key('order_attributes.${option.repository.id}.${option.id}'),
      title: Text(option.name),
      subtitle: OrderAttributeValueWidget(option.mode, option.modeValue),
      trailing: option.isDefault
          ? OutlinedText(S.orderAttributeOptionIsDefault)
          : null,
      onLongPress: () => BottomSheetActions.withDelete<int>(
        context,
        deleteValue: 0,
        warningContent: Text(S.dialogDeletionContent(option.name, '')),
        deleteCallback: () => option.remove(),
      ),
      onTap: () => Navigator.of(context).pushNamed(
        Routes.orderAttrOption,
        arguments: option,
      ),
    );
  }
}
