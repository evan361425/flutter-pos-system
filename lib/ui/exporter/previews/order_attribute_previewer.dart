import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/models/order_attribute_value_widget.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/previews/previewer_screen.dart';

class OrderAttributePreviewer extends PreviewerScreen<OrderAttribute> {
  const OrderAttributePreviewer({
    Key? key,
    required List<FormattedItem> items,
  }) : super(key: key, items: items);

  @override
  Widget getItem(BuildContext context, OrderAttribute item) {
    final mode = S.orderAttributeModeNames(item.mode.name);
    final defaultName =
        item.defaultOption?.name ?? S.orderAttributeMetaNoDefault;
    return ExpansionTile(
      title: ImporterColumnStatus(
        name: item.name,
        status: item.statusName,
      ),
      subtitle: MetaBlock.withString(context, [
        S.orderAttributeMetaMode(mode),
        S.orderAttributeMetaDefault(defaultName),
      ]),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final option in item.items)
          ListTile(
            title: Text(option.name),
            subtitle: OrderAttributeValueWidget(option.mode, option.modeValue),
            trailing: option.isDefault
                ? OutlinedText(S.orderAttributeOptionIsDefault)
                : null,
          ),
      ],
    );
  }
}
