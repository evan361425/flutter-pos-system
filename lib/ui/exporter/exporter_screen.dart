import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/exporter_routes.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class ExporterScreen extends StatefulWidget {
  const ExporterScreen({Key? key}) : super(key: key);

  @override
  State<ExporterScreen> createState() => _ExporterScreenState();
}

class _ExporterScreenState extends State<ExporterScreen>
    with SingleTickerProviderStateMixin {
  final format = DateFormat.MMMd(S.localeName);

  ExporterInfoType infoType = ExporterInfoType.order;
  late DateTimeRange range;

  late final TabController _tabController;
  late final TextEditingController startDateController;
  late final TextEditingController endDateController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.exporterTitle),
        leading: const PopButton(),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              key: Key('export.order'),
              icon: Icon(Icons.file_present_sharp),
              text: '訂單記錄',
            ),
            Tab(
                key: Key('export.menu'),
                icon: Icon(Icons.store_outlined),
                text: '商家資訊'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView(children: [
            const TextDivider(label: '請選擇訂單日期區間'),
            _buildTimeRange(),
            TextDivider(label: S.exporterDescription),
            ..._buildExporterList(),
          ]),
          ListView(children: [
            TextDivider(label: S.exporterDescription),
            ..._buildExporterList(),
          ]),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    range = DateTimeRange(start: today, end: today);
    startDateController =
        TextEditingController(text: format.format(range.start));
    endDateController = TextEditingController(text: format.format(range.end));
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  List<Widget> _buildExporterList() {
    return [
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
    ];
  }

  Widget _buildTimeRange() {
    return ExpansionTile(
      title: Row(children: [
        Flexible(
          child: TextField(
            readOnly: true,
            enabled: false,
            controller: startDateController,
            decoration: const InputDecoration(
              label: Text('起於'),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: TextField(
            readOnly: true,
            enabled: false,
            controller: endDateController,
            decoration: const InputDecoration(
              label: Text('迄至'),
            ),
          ),
        ),
      ]),
      children: [
        const Center(child: Text('垂直滑動以調整月份')),
        SfDateRangePicker(
          selectionMode: DateRangePickerSelectionMode.range,
          initialSelectedRange: PickerDateRange(range.start, range.end),
          allowViewNavigation: false, // only accept month
          navigationMode: DateRangePickerNavigationMode.scroll,
          navigationDirection: DateRangePickerNavigationDirection.vertical,
          maxDate: DateTime.now(),
          onSelectionChanged: (args) {
            final range = (args.value as PickerDateRange);
            final start = range.startDate ?? DateTime.now();
            _resetDates(start, range.endDate ?? start);
          },
        ),
      ],
    );
  }

  void _navTo(BuildContext context, ExportMethod exporterType) {
    // 對人類來說 5/1~5/2 代表兩天
    // 對機器來說 5/1~5/2 代表一天（5/1 0:0 ~ 5/2 0:0）
    final rangeForProgram = DateTimeRange(
      start: range.start,
      end: range.end.add(const Duration(days: 1)),
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: ExporterRoutes.routes[exporterType]!,
        settings: RouteSettings(
          arguments: ExporterInfo(
            type: infoType,
            range: rangeForProgram,
          ),
        ),
      ),
    );
  }

  void _resetDates(DateTime start, DateTime end) {
    range = DateTimeRange(start: start, end: end);
    startDateController.text = format.format(start);
    endDateController.text = format.format(end);
  }
}
