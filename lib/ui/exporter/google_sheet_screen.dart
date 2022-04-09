import 'package:flutter/material.dart';
import 'package:possystem/components/loading_wrapper.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/formatter/google_sheet_formatter.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';

const _exporterIdCacheKey = 'exporter_google_sheet_id';
const _exporterNameCacheKey = 'exporter_google_sheet_name';
const _importerIdCacheKey = 'importer_google_sheet_id';
const _importerNameCacheKey = 'importer_google_sheet_name';

class GoogleSheetScreen extends StatefulWidget {
  const GoogleSheetScreen({Key? key}) : super(key: key);

  @override
  State<GoogleSheetScreen> createState() => _GoogleSheetScreenState();
}

class _GoogleSheetScreenState extends State<GoogleSheetScreen> {
  final loading = GlobalKey<LoadingWrapperState>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: LoadingWrapper(
        key: loading,
        child: Scaffold(
          appBar: AppBar(
            title: Text(S.exporterGSTitle),
            leading: const PopButton(),
            bottom: const TabBar(
              tabs: [
                Tab(text: '匯出'),
                Tab(text: '匯入'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _ExporterScreen(
                startLoading: _startLoading,
                finishLoading: _finishLoading,
                setProgressStatus: _setProgressStatus,
              ),
              _ImporterScreen(
                startLoading: _startLoading,
                finishLoading: _finishLoading,
                setProgressStatus: _setProgressStatus,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startLoading() {
    loading.currentState?.startLoading();
  }

  void _finishLoading() {
    loading.currentState?.finishLoading();
  }

  void _setProgressStatus(String status) {
    loading.currentState?.setStatus(status);
  }

  @override
  void dispose() {
    loading.currentState?.dispose();
    super.dispose();
  }
}

class _ExporterScreen extends StatefulWidget {
  final void Function() startLoading;

  final void Function() finishLoading;

  final void Function(String status) setProgressStatus;

  const _ExporterScreen({
    Key? key,
    required this.startLoading,
    required this.finishLoading,
    required this.setProgressStatus,
  }) : super(key: key);

  @override
  State<_ExporterScreen> createState() => _ExporterScreenState();
}

class _ExporterScreenState extends State<_ExporterScreen> {
  final sheetSelector = GlobalKey<_SpreadsheetPickerState>();

  final sheets = <GoogleSheetAble, GlobalKey<_SheetNamerState>>{
    GoogleSheetAble.menu: GlobalKey<_SheetNamerState>(),
    GoogleSheetAble.stock: GlobalKey<_SheetNamerState>(),
    GoogleSheetAble.quantities: GlobalKey<_SheetNamerState>(),
    GoogleSheetAble.replenisher: GlobalKey<_SheetNamerState>(),
    GoogleSheetAble.customer: GlobalKey<_SheetNamerState>(),
  };

  late final FocusNode focusNode;

  GoogleSpreadsheet? spreadsheet;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        _SpreadsheetPicker(
          key: sheetSelector,
          spreadsheet: spreadsheet,
          helperText: S.exporterGSSpreadsheetHelper,
          onSheetChanged: onSheetChanged,
          onSelectStart: widget.startLoading,
          onSelectEnd: widget.finishLoading,
        ),
        ElevatedButton.icon(
          onPressed: exportData,
          focusNode: focusNode,
          label: Text(S.exporterExportButton),
          icon: const Icon(Icons.upload_file_outlined),
        ),
        const Divider(),
        for (final entry in sheets.entries)
          Row(children: [
            Expanded(
              child: _SheetNamer(
                key: entry.value,
                label: entry.key.name,
                sheets: spreadsheet?.sheets,
                initialValue: _getInitialValue(entry.key.name),
                initialChecked:
                    GoogleSheetFormatter.getTarget(entry.key).isNotEmpty,
              ),
            ),
            const SizedBox(width: 8.0),
            IconButton(
              constraints: const BoxConstraints(maxHeight: 24),
              icon: const Icon(Icons.remove_red_eye_sharp),
              tooltip: S.exporterGSPreviewerTitle(
                S.exporterGSDefaultSheetName(entry.key.name),
              ),
              onPressed: () {
                const formatter = GoogleSheetFormatter(withHeader: false);
                final target = GoogleSheetFormatter.getTarget(entry.key);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _SheetPreviewer(
                      source: _SheetPreviewerDataTableSource(
                        target.getFormattedItems(formatter),
                      ),
                      header: target.getFormattedHead(formatter),
                      title: S.exporterGSDefaultSheetName(entry.key.name),
                    ),
                  ),
                );
              },
            ),
          ]),
      ]),
    );
  }

  Future<void> onSheetChanged(GoogleSpreadsheet? newSpreadsheet) async {
    debug(newSpreadsheet.toString(), 'google_sheet_exporter.changed');
    spreadsheet = newSpreadsheet;
    for (var sheet in sheets.values) {
      sheet.currentState?.setHints(spreadsheet?.sheets);
    }

    if (spreadsheet == null) return;

    await Cache.instance.set<String>(_exporterIdCacheKey, spreadsheet!.id);
    await Cache.instance.set<String>(_exporterNameCacheKey, spreadsheet!.name);
  }

  Future<void> exportData() async {
    widget.startLoading();
    focusNode.requestFocus();

    await snackbarErrorHandler(
      context,
      _exportData,
      code: 'google_exporter_upload_failed',
    );

    widget.finishLoading();
  }

  Future<void> _exportData() async {
    final prepared = await _prepareData();
    if (prepared == null) {
      return;
    }

    Future<void> updateCacheIfNeed(String title, String label) async {
      final key = '$_exporterNameCacheKey.$label';
      if (title != Cache.instance.get<String>(key)) {
        await Cache.instance.set<String>(key, title);
      }
    }

    const formatter = GoogleSheetFormatter(withHeader: true);

    for (final entry in prepared.entries) {
      final target = GoogleSheetFormatter.getTarget(entry.key);
      final label = entry.key.name;
      widget.setProgressStatus(S.exporterGSProgressStatus('update_$label'));
      await updateCacheIfNeed(entry.value.title, label);
      await GoogleSheetExporter.instance.updateSheet(
        spreadsheet!.id,
        entry.value.id,
        target.getFormattedItems(formatter),
        target.getFormattedHead(formatter),
        hiddenColumnIndex: 1,
      );
    }
  }

  Future<bool> _addSpreadsheet(List<String> names) async {
    widget.setProgressStatus(S.exporterGSProgressStatus('add_spreadsheet'));
    final newSpreadsheet = await GoogleSheetExporter.instance.addSpreadsheet(
      S.exporterGSDefaultSpreadsheetName,
      names,
    );

    if (newSpreadsheet == null) {
      return false;
    }

    await sheetSelector.currentState?.setSheet(newSpreadsheet);
    return true;
  }

  Future<bool> _addSheets(List<String> names) async {
    widget.setProgressStatus(S.exporterGSProgressStatus('add_sheets'));
    final exist = spreadsheet!.sheets.map((e) => e.title).toSet();
    final missing = names.toSet().difference(exist);

    final newSheets = await GoogleSheetExporter.instance.addSheets(
      spreadsheet!.id,
      missing.toList(),
    );

    if (newSheets != null) {
      spreadsheet!.sheets.addAll(newSheets);
      return true;
    }

    return missing.isEmpty;
  }

  /// 準備好試算表
  ///
  /// 若沒有試算表則建立，若沒有需要的表單（例如菜單表單）也會建立好
  Future<Map<GoogleSheetAble, GoogleSheetProperties>?> _prepareData() async {
    final usedSheets = sheets.entries.where((entry) =>
        entry.value.currentState?.checked == true &&
        entry.value.currentState?.name != null);
    final names = usedSheets.map((e) => e.value.currentState!.name!).toList();

    if (names.isEmpty) {
      return null;
    } else if (names.toSet().length != names.length) {
      showErrorSnackbar(context, S.exporterGSErrors('sheet_repeat'));
      return null;
    } else if (spreadsheet == null) {
      if (!(await _addSpreadsheet(names))) {
        showErrorSnackbar(context, S.exporterGSErrors('spreadsheet'));
        return null;
      }
    } else {
      final sheets = await GoogleSheetExporter.instance.getSheets(
        spreadsheet!.id,
      );
      spreadsheet!.sheets.addAll(sheets);
    }

    if (!(await _addSheets(names))) {
      showErrorSnackbar(context, S.exporterGSErrors('sheet'));
      return null;
    }

    GoogleSheetProperties getSheetByName(String name) {
      final id =
          spreadsheet!.sheets.where((sheet) => sheet.title == name).first.id;

      return GoogleSheetProperties(id, name);
    }

    return <GoogleSheetAble, GoogleSheetProperties>{
      for (final sheet in usedSheets)
        sheet.key: getSheetByName(sheet.value.currentState!.name!)
    };
  }

  String _getInitialValue(String label) {
    return Cache.instance.get<String>('$_exporterNameCacheKey.$label') ??
        S.exporterGSDefaultSheetName(label);
  }

  @override
  void initState() {
    focusNode = FocusNode();
    final id = Cache.instance.get<String>(_exporterIdCacheKey);
    final name = Cache.instance.get<String>(_exporterNameCacheKey);
    if (id != null && name != null) {
      spreadsheet = GoogleSpreadsheet(
        id: id,
        name: name,
        sheets: [],
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    sheetSelector.currentState?.dispose();
    for (var sheet in sheets.values) {
      sheet.currentState?.dispose();
    }
    super.dispose();
  }
}

class _ImporterScreen extends StatefulWidget {
  final void Function() startLoading;

  final void Function() finishLoading;

  final void Function(String status) setProgressStatus;

  const _ImporterScreen({
    Key? key,
    required this.startLoading,
    required this.finishLoading,
    required this.setProgressStatus,
  }) : super(key: key);

  @override
  State<_ImporterScreen> createState() => _ImporterScreenState();
}

class _ImporterScreenState extends State<_ImporterScreen> {
  final loading = GlobalKey<LoadingWrapperState>();
  final sheetSelector = GlobalKey<_SpreadsheetPickerState>();

  final sheets = <GoogleSheetAble, GlobalKey<_SheetSelectorState>>{
    GoogleSheetAble.menu: GlobalKey<_SheetSelectorState>(),
    GoogleSheetAble.stock: GlobalKey<_SheetSelectorState>(),
    GoogleSheetAble.quantities: GlobalKey<_SheetSelectorState>(),
    GoogleSheetAble.replenisher: GlobalKey<_SheetSelectorState>(),
    GoogleSheetAble.customer: GlobalKey<_SheetSelectorState>(),
  };

  GoogleSpreadsheet? spreadsheet;

  @override
  Widget build(BuildContext context) {
    return LoadingWrapper(
      key: loading,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _SpreadsheetPicker(
            key: sheetSelector,
            spreadsheet: spreadsheet,
            allowEmpty: false,
            helperText: '應用程式感知不到你的試算表有異動，重新整理可以重新找到擁有的表單。',
            onSheetChanged: onSheetChanged,
            onSelectStart: widget.startLoading,
            onSelectEnd: widget.finishLoading,
          ),
          const SizedBox(height: 4.0),
          ElevatedButton.icon(
            onPressed: refreshSheet,
            label: const Text('重整試算表'),
            icon: const Icon(Icons.refresh_outlined),
          ),
          const Divider(),
          for (final entry in sheets.entries)
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                child: _SheetSelector(
                  key: entry.value,
                  label: S.exporterGSSheetLabel(
                    S.exporterGSDefaultSheetName(entry.key.name),
                  ),
                  defaultValue: _getInitialValue(entry.key.name),
                ),
              ),
              const SizedBox(width: 8.0),
              OutlinedButton.icon(
                onPressed: () => importData(entry.key),
                label: const Text('匯入'),
                icon: const Icon(Icons.download_for_offline_outlined),
              ),
            ]),
        ]),
      ),
    );
  }

  Future<void> onSheetChanged(GoogleSpreadsheet? newSpreadsheet) async {
    debug(newSpreadsheet.toString(), 'google_sheet_importer.changed');
    spreadsheet = newSpreadsheet;
    for (var sheet in sheets.values) {
      sheet.currentState?.setSheets(spreadsheet!.sheets);
    }

    await Cache.instance.set<String>(_importerIdCacheKey, spreadsheet!.id);
    await Cache.instance.set<String>(_importerNameCacheKey, spreadsheet!.name);
  }

  Future<void> refreshSheet() async {
    if (spreadsheet == null) {
      showInfoSnackbar(context, '請先選擇試算表');
      return;
    }

    loading.currentState?.startLoading();

    await snackbarErrorHandler(
      context,
      _refreshSheet,
      code: 'google_sheet_get_sheets',
    );

    loading.currentState?.finishLoading();
  }

  Future<void> importData(GoogleSheetAble type) async {
    widget.startLoading();

    await snackbarErrorHandler(
      context,
      () => _importData(type),
      code: 'google_importer_import_failed',
    );

    widget.finishLoading();
  }

  Future<void> _refreshSheet() async {
    final refreshedSheets = await GoogleSheetExporter.instance.getSheets(
      spreadsheet!.id,
    );

    if (refreshedSheets.isNotEmpty) {
      spreadsheet!.sheets.addAll(refreshedSheets);
      for (var sheet in sheets.values) {
        sheet.currentState?.setSheets(refreshedSheets);
      }
    }
  }

  Future<void> _importData(GoogleSheetAble type) async {
    final prepared = await _prepareData(type);
    if (prepared == null) {
      return;
    }

    final key = '$_importerNameCacheKey.${type.name}';
    if (prepared.toCacheValue() != Cache.instance.get<String>(key)) {
      await Cache.instance.set<String>(key, prepared.toCacheValue());
    }

    await Future.delayed(const Duration(seconds: 5));
  }

  Future<GoogleSheetProperties?> _prepareData(GoogleSheetAble type) async {
    if (spreadsheet == null) {
      showErrorSnackbar(context, '必須選擇試算表來匯入');
      return null;
    } else if (sheets[type]?.currentState?.selected == null) {
      showErrorSnackbar(context, '必須選擇指定的表單來匯入');
      return null;
    }

    return sheets[type]?.currentState?.selected;
  }

  GoogleSheetProperties? _getInitialValue(String label) {
    final nameId = Cache.instance.get<String>('$_importerNameCacheKey.$label');

    return GoogleSheetProperties.fromCacheValue(nameId);
  }

  @override
  void initState() {
    final id = Cache.instance.get<String>(_importerIdCacheKey);
    final name = Cache.instance.get<String>(_importerNameCacheKey);
    if (id != null && name != null) {
      spreadsheet = GoogleSpreadsheet(
        id: id,
        name: name,
        sheets: [],
      );
      refreshSheet();
    }
    super.initState();
  }

  @override
  void dispose() {
    loading.currentState?.dispose();
    sheetSelector.currentState?.dispose();
    for (var sheet in sheets.values) {
      sheet.currentState?.dispose();
    }
    super.dispose();
  }
}

class _SpreadsheetPicker extends StatefulWidget {
  final Future<void> Function(GoogleSpreadsheet?) onSheetChanged;

  final void Function() onSelectStart;

  final void Function() onSelectEnd;

  final GoogleSpreadsheet? spreadsheet;

  final bool allowEmpty;

  final String? helperText;

  const _SpreadsheetPicker({
    Key? key,
    this.spreadsheet,
    required this.onSheetChanged,
    required this.onSelectStart,
    required this.onSelectEnd,
    this.allowEmpty = true,
    this.helperText,
  }) : super(key: key);

  @override
  State<_SpreadsheetPicker> createState() => _SpreadsheetPickerState();
}

class _SpreadsheetPickerState extends State<_SpreadsheetPicker> {
  late TextEditingController _controller;

  GoogleSpreadsheet? spreadsheet;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      readOnly: true,
      onTap: () async {
        widget.onSelectStart();
        final result = await GoogleSheetExporter.instance.pickSheet();
        if (result == null) {
          showInfoSnackbar(context, '找不到，試算表是否已被刪除？');
        } else {
          setSheet(result);
        }
        widget.onSelectEnd();
      },
      decoration: InputDecoration(
        labelText: S.exporterGSSpreadsheetLabel,
        hintText: S.exporterGSSpreadsheetHint,
        helperText: widget.helperText,
        helperMaxLines: 3,
        border: const OutlineInputBorder(),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffix: widget.allowEmpty
            ? GestureDetector(
                onTap: () => setSheet(null),
                child: const Icon(KIcons.clear, size: 16.0),
              )
            : null,
      ),
    );
  }

  Future<void> setSheet(GoogleSpreadsheet? newSheet) {
    _controller.text = newSheet?.name ?? '';
    spreadsheet = newSheet;
    return widget.onSheetChanged(newSheet);
  }

  @override
  void initState() {
    spreadsheet = widget.spreadsheet;
    _controller = TextEditingController(text: spreadsheet?.name);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _SheetNamer extends StatefulWidget {
  final String initialValue;

  final String label;

  final bool initialChecked;

  final List<GoogleSheetProperties>? sheets;

  const _SheetNamer({
    Key? key,
    required this.initialValue,
    required this.label,
    required this.initialChecked,
    this.sheets,
  }) : super(key: key);

  @override
  State<_SheetNamer> createState() => _SheetNamerState();
}

class _SheetNamerState extends State<_SheetNamer> {
  Iterable<String>? autofillHints;

  late TextEditingController _controller;

  late bool checked;

  String? get name => _controller.text.isEmpty ? null : _controller.text;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofillHints: autofillHints,
      decoration: InputDecoration(
        prefix: SizedBox(
          height: 14,
          child: Checkbox(
            value: checked,
            visualDensity: VisualDensity.compact,
            splashRadius: 0,
            onChanged: (newValue) => setState(() => checked = newValue!),
          ),
        ),
        labelText: S.exporterGSSheetLabel(
          S.exporterGSDefaultSheetName(widget.label),
        ),
        hintText: widget.initialValue,
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  void setHints(List<GoogleSheetProperties>? sheets) {
    setState(() => _setHints(sheets));
  }

  void _setHints(List<GoogleSheetProperties>? sheets) {
    autofillHints = sheets?.map((e) => e.title);
  }

  @override
  void initState() {
    checked = widget.initialChecked;
    _controller = TextEditingController(text: widget.initialValue);
    _setHints(widget.sheets);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _SheetSelector extends StatefulWidget {
  final GoogleSheetProperties? defaultValue;

  final String label;

  const _SheetSelector({
    Key? key,
    this.defaultValue,
    required this.label,
  }) : super(key: key);

  @override
  State<_SheetSelector> createState() => _SheetSelectorState();
}

class _SheetSelectorState extends State<_SheetSelector> {
  late List<GoogleSheetProperties> sheets;

  GoogleSheetProperties? selected;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<GoogleSheetProperties>(
      value: selected,
      decoration: InputDecoration(
        label: Text(widget.label),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      onChanged: (newSelected) => setState(() => selected = newSelected),
      items: [
        for (var sheet in sheets)
          DropdownMenuItem(
            value: sheet,
            child: Text(sheet.title),
          ),
      ],
    );
  }

  setSheets(List<GoogleSheetProperties> newSheets) {
    setState(() {
      sheets = newSheets;
    });
  }

  @override
  void initState() {
    selected = widget.defaultValue;
    sheets = selected != null ? [selected!] : const [];
    super.initState();
  }
}

class _SheetPreviewer extends StatelessWidget {
  final _SheetPreviewerDataTableSource source;

  final String title;

  final List<GoogleSheetCellData> header;

  const _SheetPreviewer({
    Key? key,
    required this.source,
    required this.title,
    required this.header,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: const PopButton(),
      ),
      body: SingleChildScrollView(
        child: PaginatedDataTable(
          columns: [
            for (final cell in header)
              DataColumn(
                label: Text(
                  cell.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                tooltip: cell.note,
              ),
          ],
          source: source,
          showCheckboxColumn: false,
        ),
      ),
    );
  }
}

class _SheetPreviewerDataTableSource extends DataTableSource {
  final List<List<GoogleSheetCellData>> data;

  _SheetPreviewerDataTableSource(this.data);

  @override
  DataRow? getRow(int index) {
    return DataRow(cells: [
      for (final item in data[index])
        DataCell(Tooltip(
          message: item.toString(),
          child: Text(item.toString()),
        )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
