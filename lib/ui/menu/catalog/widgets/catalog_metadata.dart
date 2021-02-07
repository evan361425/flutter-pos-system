import 'package:flutter/material.dart';
import 'package:possystem/components/label_switch.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:provider/provider.dart';

class CatalogMetadata extends StatefulWidget {
  @override
  _CatalogMetadataState createState() => _CatalogMetadataState();
}

class _CatalogMetadataState extends State<CatalogMetadata> {
  // Change result immediatly instead of after DB finish
  bool _isEnable;
  CatalogModel catalog;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    catalog = context.read<CatalogModel>();
    _isEnable = catalog.enable;
  }

  @override
  Widget build(BuildContext context) {
    if (!catalog.isReady) return SizedBox(height: defaultPadding);

    // make it right, easy to click by right thumb
    return Align(
      alignment: Alignment.centerRight,
      child: LabeledSwitch(
        label: '啟用',
        tooltip: '是否顯示在點餐系統',
        onChanged: (checked) {
          setState(() => _isEnable = checked);
          catalog.setEnable(checked, context).whenComplete(() {
            setState(() => _isEnable = catalog.enable);
          });
        },
        value: _isEnable,
      ),
    );
  }
}
