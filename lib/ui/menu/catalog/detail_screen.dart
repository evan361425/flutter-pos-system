import 'package:flutter/material.dart';
import 'package:possystem/app_localizations.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/ui/menu/catalog/widgets/body.dart';
import 'package:possystem/ui/menu/catalog/widgets/name_editor.dart';
import 'package:provider/provider.dart';

class CatalogDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CatalogModel catalog = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          catalog == null
              ? Trans.of(context).t('menu.catalog.title.add')
              : Trans.of(context).t('menu.catalog.title.edit'),
        ),
      ),
      body: Provider<CatalogModel>(
        create: (_) => catalog,
        child: Column(
          children: [
            NameEditor(),
            Container(
              padding: EdgeInsets.only(bottom: defaultPadding),
              child: Divider(),
            ),
            Body(),
          ],
        ),
      ),
    );
  }
}
