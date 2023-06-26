import 'package:flutter/material.dart';
import 'package:possystem/components/choice_chip_with_help.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/exporter_routes.dart';

class ExporterScreen extends StatelessWidget {
  final infoTypeSelector =
      GlobalKey<ChoiceChipWithHelpState<ExporterInfoType>>();

  ExporterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.exporterTitle),
        leading: const PopButton(),
      ),
      body: ListView(children: [
        ChoiceChipWithHelp<ExporterInfoType>(
          key: infoTypeSelector,
          values: ExporterInfoType.values,
          selected: ExporterInfoType.order,
          labels: const ['訂單記錄', '商家資訊'],
          helpTexts: const [
            '訂單資訊可以讓你匯出到第三方位置後做更細緻的統計分析。',
            '商家資訊通常是用來把菜單、庫存等資訊同步到第三方位置或用來匯入到另一台手機。',
          ],
        ),
        TextDivider(label: S.exporterDescription),
        ListTile(
          key: const Key('exporter.google_sheet'),
          leading: CircleAvatar(
            backgroundImage: const AssetImage('assets/google_sheet_icon.png'),
            backgroundColor: Theme.of(context).focusColor,
            radius: 24,
          ),
          title: Text(S.exporterGSTitle),
          subtitle: Text(S.exporterGSDescription),
          onTap: () => _navTo(context, ExportMethod.googleSheet),
        ),
        ListTile(
          key: const Key('exporter.plain_text'),
          leading: const CircleAvatar(
            radius: 24,
            child: Text('Text'),
          ),
          title: const Text('純文字'),
          subtitle: const Text('有些人就愛這味。就像資料分析師說的那樣：請給我生魚片，不要煮過的。'),
          onTap: () => _navTo(context, ExportMethod.plainText),
        ),
      ]),
    );
  }

  void _navTo(BuildContext context, ExportMethod exporterType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: ExporterRoutes.routes[exporterType]!,
        settings: RouteSettings(
          arguments:
              infoTypeSelector.currentState?.selected ?? ExporterInfoType.order,
        ),
      ),
    );
  }
}
