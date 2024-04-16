import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/choice_chip_with_help.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

import 'transit_station.dart';

class TransitPage extends StatefulWidget {
  const TransitPage({super.key});

  @override
  State<TransitPage> createState() => _TransitPageState();
}

class _TransitPageState extends State<TransitPage> {
  final selector = GlobalKey<ChoiceChipWithHelpState<TransitType>>();

  @override
  Widget build(BuildContext context) {
    final body = ListView(children: [
      ChoiceChipWithHelp<TransitType>(
        key: selector,
        values: TransitType.values,
        selected: TransitType.order,
        labels: TransitType.values.map((e) => S.transitDataName(e.name)).toList(),
        helpTexts: TransitType.values.map((e) => S.transitDataHelper(e.name)).toList(),
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
        subtitle: const Text('快速檢查、快速分享。'),
        onTap: () => _goToStation(context, TransitMethod.plainText),
      ),
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.transitTitleMain),
        leading: const PopButton(),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          selector.currentState?.updateSelectedIndex(
            details.velocity.pixelsPerSecond.dx,
          );
        },
        // fill the screen to allow drag from white space
        child: SizedBox(height: double.infinity, child: body),
      ),
    );
  }

  void _goToStation(BuildContext context, TransitMethod method) {
    context.pushNamed(Routes.transitStation, pathParameters: {
      'method': method.name,
      'type': selector.currentState?.selected.name ?? 'order',
    });
  }
}
