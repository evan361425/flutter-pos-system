import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/choice_chip_with_help.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

import 'transit_station.dart';

class TransitPage extends StatefulWidget {
  const TransitPage({super.key});

  @override
  State<TransitPage> createState() => _TransitPageState();
}

class _TransitPageState extends State<TransitPage> {
  final selector = GlobalKey<ChoiceChipWithHelpState<TransitCatalog>>();

  @override
  Widget build(BuildContext context) {
    final list = ListView(children: [
      ChoiceChipWithHelp<TransitCatalog>(
        key: selector,
        values: TransitCatalog.values,
        selected: TransitCatalog.order,
        labels: TransitCatalog.values.map((e) => S.transitCatalogName(e.name)).toList(),
        helpTexts: TransitCatalog.values.map((e) => S.transitCatalogHelper(e.name)).toList(),
      ),
      TextDivider(label: S.transitMethodTitle),
      ListTile(
        key: const Key('transit.google_sheet'),
        leading: CircleAvatar(
          radius: 24,
          child: SvgPicture.asset(
            'assets/google_sheet_icon.svg',
            width: 24,
          ),
        ),
        title: Text(S.transitMethodName(TransitMethod.googleSheet.name)),
        subtitle: Text(S.transitGSDescription),
        onTap: () => _goToStation(context, TransitMethod.googleSheet),
      ),
      ListTile(
        key: const Key('transit.plain_text'),
        leading: const CircleAvatar(
          radius: 24,
          child: Text('Text'),
        ),
        title: Text(S.transitMethodName(TransitMethod.plainText.name)),
        subtitle: Text(S.transitPTDescription),
        onTap: () => _goToStation(context, TransitMethod.plainText),
      ),
      const SizedBox(height: kFABSpacing),
    ]);

    // allow scroll as TabView
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        selector.currentState?.updateSelectedIndex(
          details.velocity.pixelsPerSecond.dx,
        );
      },
      // fill the screen to allow drag from white space
      child: SizedBox(height: double.infinity, child: list),
    );
  }

  void _goToStation(BuildContext context, TransitMethod method) {
    context.pushNamed(Routes.transitStation, pathParameters: {
      'method': method.name,
      'type': selector.currentState?.selected.name ?? 'order',
    });
  }
}
