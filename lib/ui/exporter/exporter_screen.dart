import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/settings/language_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/exporter_routes.dart';

class ExporterScreen extends StatefulWidget {
  const ExporterScreen({Key? key}) : super(key: key);

  @override
  State<ExporterScreen> createState() => _ExporterScreenState();
}

class _ExporterScreenState extends State<ExporterScreen> {
  final format = DateFormat.MMMd(S.localeName);

  ExporterInfoType type = ExporterInfoType.order;
  late DateTime startDate;
  late DateTime endDate;

  late final TextEditingController startDateController;
  late final TextEditingController endDateController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.exporterTitle),
        leading: const PopButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('選擇欲匯入匯出的資訊：'),
            const SizedBox(height: 8),
            _buildDropdown(),
          ]),
          if (type == ExporterInfoType.order) _buildTimeRange(),
          const Divider(),
          Center(child: HintText(S.exporterDescription)),
          ListTile(
            key: const Key('exporter.google_sheet'),
            leading: CircleAvatar(
              backgroundImage: const AssetImage('assets/google_sheet_icon.png'),
              backgroundColor: Theme.of(context).focusColor,
              radius: 24,
            ),
            title: Text(S.exporterGSTitle),
            subtitle: Text(S.exporterGSDescription),
            onTap: () => _navTo(context, ExporterRoutes.googleSheet),
          ),
          ListTile(
            key: const Key('exporter.plain_text'),
            leading: const CircleAvatar(
              radius: 24,
              child: Text('Text'),
            ),
            title: const Text('純文字'),
            subtitle: const Text('有些人就愛這味。就像資料分析師說的那樣：請給我生魚片，不要煮過的。'),
            onTap: () => _navTo(context, ExporterRoutes.plainText),
          ),
        ]),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    endDate = DateTime.now();
    startDate = endDate.subtract(const Duration(days: 1));
    startDateController = TextEditingController(text: format.format(startDate));
    endDateController = TextEditingController(text: format.format(endDate));
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  Widget _buildDropdown() {
    return DropdownButton<ExporterInfoType>(
      items: const [
        DropdownMenuItem(value: ExporterInfoType.basic, child: Text('商家資訊')),
        DropdownMenuItem(value: ExporterInfoType.order, child: Text('訂單記錄')),
      ],
      value: type,
      onChanged: (type) {
        if (type != null) {
          setState(() {
            this.type = type;
          });
        }
      },
    );
  }

  Widget _buildTimeRange() {
    return Column(
      children: [
        const Center(child: HintText('選擇訂單日期區間')),
        Row(children: [
          Flexible(
            child: TextFormField(
              readOnly: true,
              controller: startDateController,
              onTap: _pickDateRange,
              decoration: const InputDecoration(
                label: Text('起於'),
                helperText: '含這天的資料',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: TextFormField(
              readOnly: true,
              controller: endDateController,
              onTap: _pickDateRange,
              decoration: const InputDecoration(
                label: Text('迄至'),
                helperText: '不會包含這天的資料',
              ),
            ),
          ),
        ]),
      ],
    );
  }

  void _navTo(BuildContext context, String name) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: ExporterRoutes.routes[name]!,
        settings: RouteSettings(
          arguments: ExporterInfo(
            type: type,
            startDate: startDate,
            endDate: endDate,
          ),
        ),
      ),
    );
  }

  void _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      locale: SettingsProvider.of<LanguageSetting>().value,
      firstDate: DateTime(2021, 1),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (range != null) {
      startDate = range.start;
      endDate = range.end;
      setState(() {
        startDateController.text = format.format(startDate);
        endDateController.text = format.format(endDate);
      });
    }
  }
}
