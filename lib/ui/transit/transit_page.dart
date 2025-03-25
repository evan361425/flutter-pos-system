import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

import 'transit_station.dart';

class TransitPage extends StatelessWidget {
  const TransitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      ListTile(
        key: const Key('transit.google_sheet'),
        leading: CircleAvatar(
          radius: 24,
          child: SvgPicture.asset('assets/google_sheet_icon.svg', width: 24),
        ),
        title: Text(TransitMethod.googleSheet.l10nName),
        subtitle: Text(S.transitDescriptionGoogleSheet),
        onTap: () => _next(context, TransitMethod.googleSheet),
      ),
      ListTile(
        key: const Key('transit.excel'),
        leading: CircleAvatar(
          radius: 24,
          child: SvgPicture.asset('assets/excel_icon.svg', width: 24),
        ),
        title: Text(TransitMethod.excel.l10nName),
        subtitle: Text(S.transitDescriptionExcel),
        onTap: () => _next(context, TransitMethod.excel),
      ),
      ListTile(
        key: const Key('transit.csv'),
        leading: const CircleAvatar(
          radius: 24,
          child: Text('CSV'),
        ),
        title: Text(TransitMethod.csv.l10nName),
        subtitle: Text(S.transitDescriptionCsv),
        onTap: () => _next(context, TransitMethod.csv),
      ),
      ListTile(
        key: const Key('transit.plain_text'),
        leading: const CircleAvatar(
          radius: 24,
          child: Text('Text'),
        ),
        title: Text(TransitMethod.plainText.l10nName),
        subtitle: Text(S.transitDescriptionPlainText),
        onTap: () => _next(context, TransitMethod.plainText),
      ),
      const SizedBox(height: kFABSpacing),
    ]);
  }

  void _next(BuildContext context, TransitMethod method) async {
    final catalog = await showAdaptiveDialog<TransitCatalog>(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: Text('用 ${method.l10nName} 做什麼？'),
          content: Column(children: [
            for (final catalog in TransitCatalog.values)
              ListTile(
                title: Text(catalog.l10nName),
                subtitle: Text(catalog.l10nHelper),
                onTap: () => Navigator.of(context).pop(catalog),
              ),
          ]),
        );
      },
    );

    if (catalog != null && context.mounted) {
      context.pushNamed(Routes.transitStation, pathParameters: {
        'method': method.name,
        'catalog': catalog.name,
      });
    }
  }
}
