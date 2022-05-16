import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/previews/previewer_screen.dart';

class CustomerSettingPreviewer extends PreviewerScreen<CustomerSetting> {
  const CustomerSettingPreviewer({
    Key? key,
    required List<FormattedItem> items,
  }) : super(key: key, items: items);

  @override
  Widget getItem(BuildContext context, CustomerSetting item) {
    final mode = S.customerSettingModeNames(item.mode);
    final defaultName =
        item.defaultOption?.name ?? S.customerSettingMetaNoDefault;
    return ExpansionTile(
      title: ImporterColumnStatus(
        name: item.name,
        status: item.statusName,
      ),
      subtitle: MetaBlock.withString(context, [
        S.customerSettingMetaMode(mode),
        S.customerSettingMetaDefault(defaultName),
      ]),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final option in item.itemList)
          ListTile(
            title: Text(option.name),
            subtitle: option.modeValueName.isEmpty
                ? null
                : Text(option.modeValueName),
            trailing: option.isDefault
                ? OutlinedText(S.customerSettingOptionIsDefault)
                : null,
          ),
      ],
    );
  }
}
