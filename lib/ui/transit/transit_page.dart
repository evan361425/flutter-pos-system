import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/choice_chip_with_help.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

import 'transit_station.dart';

class TransitPage extends StatefulWidget {
  const TransitPage({Key? key}) : super(key: key);

  @override
  State<TransitPage> createState() => _TransitPageState();
}

class _TransitPageState extends State<TransitPage> {
  final selector = GlobalKey<ChoiceChipWithHelpState<TransitType>>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.transitTitle),
        leading: const PopButton(),
      ),
      body: ListView(children: [
        ChoiceChipWithHelp<TransitType>(
          key: selector,
          values: TransitType.values,
          selected: TransitType.order,
          labels: const ['訂單記錄', '商家資訊'],
          helpTexts: const [
            '訂單資訊可以讓你匯出到第三方位置後做更細緻的統計分析。',
            '商家資訊通常是用來把菜單、庫存等資訊同步到第三方位置或用來匯入到另一台手機。',
          ],
        ),
        TextDivider(label: S.transitDescription),
        ListTile(
          key: const Key('exporter.google_sheet'),
          leading: CircleAvatar(
            backgroundImage: const AssetImage('assets/google_sheet_icon.png'),
            backgroundColor: Theme.of(context).focusColor,
            radius: 24,
          ),
          title: Text(S.transitMethod(TransitMethod.googleSheet.name)),
          subtitle: Text(S.transitGSDescription),
          onTap: () => _goToStation(context, TransitMethod.googleSheet),
        ),
        ListTile(
          key: const Key('exporter.plain_text'),
          leading: const CircleAvatar(
            radius: 24,
            child: Text('Text'),
          ),
          title: Text(S.transitMethod(TransitMethod.plainText.name)),
          subtitle: const Text('快速檢查、快速分享。'),
          onTap: () => _goToStation(context, TransitMethod.plainText),
        ),
      ]),
    );
  }

  void _goToStation(BuildContext context, TransitMethod method) {
    context.pushNamed(Routes.transitStation, pathParameters: {
      'method': method.name,
      'type': selector.currentState?.selected.name ?? 'order',
    });
  }
}
