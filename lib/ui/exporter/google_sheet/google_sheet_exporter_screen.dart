import 'package:flutter/material.dart';
import 'package:possystem/components/loading_wrapper.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/formatter/google_sheet_formatter.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';

const _sheetIdCacheKey = 'exporter_google_sheet_id';
const _sheetNameCacheKey = 'exporter_google_sheet_name';

class GoogleSheetExporterScreen extends StatefulWidget {
  const GoogleSheetExporterScreen({Key? key}) : super(key: key);

  @override
  State<GoogleSheetExporterScreen> createState() => _ExporterScreenState();
}

class _ExporterScreenState extends State<GoogleSheetExporterScreen> {
  final sheetSelector = GlobalKey<_SheetSelectorState>();

  final loading = GlobalKey<LoadingWrapperState>();

  late final FocusNode focusNode;

  GoogleSpreadsheet? sheet;

  List<String> get missingSheets => sheetNames
      .toSet()
      .difference(sheet?.sheets.map((e) => e.title).toSet() ?? const {})
      .toList();

  List<String> get sheetNames => [
        _menuSheetName,
        _stockSheetName,
        _quantitiesSheetName,
        _replenisherSheetName,
        _customerSheetName,
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.exporterGSTitle),
        leading: const PopButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: LoadingWrapper(
          key: loading,
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _SheetSelector(
              key: sheetSelector,
              sheet: sheet,
              onSheetChanged: onSheetChanged,
              onSelectStart: _startLoading,
              onSelectEnd: _finishLoading,
            ),
            ElevatedButton.icon(
              onPressed: uploadData,
              focusNode: focusNode,
              label: Text(S.exporterExportButton),
              icon: const Icon(Icons.upload_file_outlined),
            ),
            const Divider(),
            _SheetNamer(
              key: menuNamer,
              label: 'menu',
              sheets: sheet?.sheets,
              initialValue: _menuSheetName,
              getSource: Menu.instance.getGoogleSheetItems,
              getHeader: Menu.instance.getGoogleSheetHeader,
            ),
            _SheetNamer(
              key: stockNamer,
              label: 'stock',
              sheets: sheet?.sheets,
              initialValue: _stockSheetName,
              getSource: Stock.instance.getGoogleSheetItems,
              getHeader: Stock.instance.getGoogleSheetHeader,
            ),
            _SheetNamer(
              key: quantitiesNamer,
              label: 'quantities',
              sheets: sheet?.sheets,
              initialValue: _quantitiesSheetName,
              getSource: Quantities.instance.getGoogleSheetItems,
              getHeader: Quantities.instance.getGoogleSheetHeader,
            ),
            _SheetNamer(
              key: replenisherNamer,
              label: 'replenisher',
              sheets: sheet?.sheets,
              initialValue: _replenisherSheetName,
              getSource: Replenisher.instance.getGoogleSheetItems,
              getHeader: Replenisher.instance.getGoogleSheetHeader,
            ),
            _SheetNamer(
              key: customerNamer,
              label: 'customer',
              sheets: sheet?.sheets,
              initialValue: _customerSheetName,
              getSource: CustomerSettings.instance.getGoogleSheetItems,
              getHeader: CustomerSettings.instance.getGoogleSheetHeader,
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> onSheetChanged(GoogleSpreadsheet? newSheet) async {
    debug(newSheet.toString(), 'exporter.google_sheet_changed');
    sheet = newSheet;
    menuNamer.currentState?.setHints(sheet?.sheets);

    if (sheet != null) {
      await Cache.instance.set<String>(_sheetIdCacheKey, sheet!.id);
      await Cache.instance.set<String>(_sheetNameCacheKey, sheet!.name);
    }
  }

  Future<void> uploadData() async {
    try {
      focusNode.requestFocus();
      _startLoading();
      await _uploadData();
    } catch (e) {
      showErrorSnackbar(context, S.actError);
      error(e.toString(), 'google_exporter_upload_failed');
    } finally {
      _finishLoading();
    }
  }

  Future<void> _uploadData() async {
    final prepared = await _prepareSpreadsheet();
    if (prepared == null) {
      return;
    }

    await _updateCacheNameIfNeed();

    _setStatus('update_menu');
    await GoogleSheetExporter.instance.updateSheet(
      prepared.spreadsheetId,
      prepared.menuSheetId,
      Menu.instance.getGoogleSheetItems(withHeader: true),
      Menu.instance.getGoogleSheetHeader(withHeader: true),
      hiddenColumnIndex: 1,
    );

    _setStatus('update_stock');
    await GoogleSheetExporter.instance.updateSheet(
      prepared.spreadsheetId,
      prepared.stockSheetId,
      Stock.instance.getGoogleSheetItems(withHeader: true),
      Stock.instance.getGoogleSheetHeader(withHeader: true),
      hiddenColumnIndex: 1,
    );

    _setStatus('update_quantities');
    await GoogleSheetExporter.instance.updateSheet(
      prepared.spreadsheetId,
      prepared.quantitiesSheetId,
      Quantities.instance.getGoogleSheetItems(withHeader: true),
      Quantities.instance.getGoogleSheetHeader(withHeader: true),
      hiddenColumnIndex: 1,
    );

    _setStatus('update_replenisher');
    await GoogleSheetExporter.instance.updateSheet(
      prepared.spreadsheetId,
      prepared.replenisherSheetId,
      Replenisher.instance.getGoogleSheetItems(withHeader: true),
      Replenisher.instance.getGoogleSheetHeader(withHeader: true),
      hiddenColumnIndex: 1,
    );

    _setStatus('update_customer');
    await GoogleSheetExporter.instance.updateSheet(
      prepared.spreadsheetId,
      prepared.customerSheetId,
      CustomerSettings.instance.getGoogleSheetItems(withHeader: true),
      CustomerSettings.instance.getGoogleSheetHeader(withHeader: true),
      hiddenColumnIndex: 1,
    );
  }

  /// 準備好試算表
  ///
  /// 若沒有試算表則建立，若沒有需要的表單（例如菜單表單）也會建立好
  Future<_GoogleUsedSheets?> _prepareSpreadsheet() async {
    final names = sheetNames;
    if (names.toSet().length != names.length) {
      showErrorSnackbar(context, S.exporterGSErrors('sheet_repeat'));
      return null;
    }

    if (sheet == null) {
      _setStatus('add_spreadsheet');
      final newSheet = await GoogleSheetExporter.instance.addSpreadsheet(
        S.exporterGSDefaultSpreadsheetName,
        names,
      );

      if (newSheet == null) {
        showErrorSnackbar(context, S.exporterGSErrors('spreadsheet'));
        return null;
      }
      await sheetSelector.currentState?.setSheet(newSheet);
    } else {
      final sheets = await GoogleSheetExporter.instance.getSheets(sheet!.id);
      sheet!.sheets.addAll(sheets);
    }

    _setStatus('add_sheets');
    final newSheets = await GoogleSheetExporter.instance.addSheets(
      sheet!.id,
      missingSheets,
    );
    sheet!.sheets.addAll(newSheets ?? const []);

    if (missingSheets.isNotEmpty) {
      showErrorSnackbar(context, S.exporterGSErrors('sheet'));
      return null;
    }

    int findSheetIdByName(String name) {
      return sheet!.sheets.where((sheet) => sheet.title == name).first.id;
    }

    return _GoogleUsedSheets(
      spreadsheetId: sheet!.id,
      menuSheetId: findSheetIdByName(_menuSheetName),
      stockSheetId: findSheetIdByName(_stockSheetName),
      quantitiesSheetId: findSheetIdByName(_quantitiesSheetName),
      replenisherSheetId: findSheetIdByName(_replenisherSheetName),
      customerSheetId: findSheetIdByName(_customerSheetName),
    );
  }

  @override
  void initState() {
    focusNode = FocusNode();
    final id = Cache.instance.get<String>(_sheetIdCacheKey);
    final name = Cache.instance.get<String>(_sheetNameCacheKey);
    if (id != null && name != null) {
      sheet = GoogleSpreadsheet(
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
    super.dispose();
  }

  void _startLoading() {
    loading.currentState?.startLoading();
  }

  void _finishLoading() {
    loading.currentState?.finishLoading();
  }

  void _setStatus(String status) {
    loading.currentState?.setStatus(S.exporterGSProgressStatus(status));
  }

  final menuNamer = GlobalKey<_SheetNamerState>();
  final stockNamer = GlobalKey<_SheetNamerState>();
  final quantitiesNamer = GlobalKey<_SheetNamerState>();
  final replenisherNamer = GlobalKey<_SheetNamerState>();
  final customerNamer = GlobalKey<_SheetNamerState>();

  String _getName(GlobalKey<_SheetNamerState> key, String label) {
    return key.currentState?.name ??
        Cache.instance.get<String>('$_sheetNameCacheKey.$label') ??
        S.exporterGSDefaultSheetName(label);
  }

  String get _menuSheetName => _getName(menuNamer, 'menu');
  String get _stockSheetName => _getName(stockNamer, 'stock');
  String get _quantitiesSheetName => _getName(quantitiesNamer, 'quantities');
  String get _replenisherSheetName => _getName(replenisherNamer, 'replenisher');
  String get _customerSheetName => _getName(customerNamer, 'customer');

  Future<void> _updateCacheNameIfNeed() async {
    Future<void> _u(String label, String value) async {
      if (value != Cache.instance.get<String>('$_sheetNameCacheKey.$label')) {
        await Cache.instance.set<String>('$_sheetNameCacheKey.$label', value);
      }
    }

    await _u('menu', _menuSheetName);
    await _u('stock', _stockSheetName);
    await _u('quantities', _quantitiesSheetName);
    await _u('replenisher', _replenisherSheetName);
    await _u('customer', _customerSheetName);
  }
}

class _SheetSelector extends StatefulWidget {
  final Future<void> Function(GoogleSpreadsheet?) onSheetChanged;

  final void Function() onSelectStart;

  final void Function() onSelectEnd;

  final GoogleSpreadsheet? sheet;

  const _SheetSelector({
    Key? key,
    this.sheet,
    required this.onSheetChanged,
    required this.onSelectStart,
    required this.onSelectEnd,
  }) : super(key: key);

  @override
  State<_SheetSelector> createState() => _SheetSelectorState();
}

class _SheetSelectorState extends State<_SheetSelector> {
  late TextEditingController _idController;

  GoogleSpreadsheet? sheet;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _idController,
      readOnly: true,
      onTap: () async {
        widget.onSelectStart();
        final result = await GoogleSheetExporter.instance.pickSheet();
        if (result != null) {
          setSheet(result);
        }
        widget.onSelectEnd();
      },
      decoration: InputDecoration(
        labelText: S.exporterGSSpreadsheetLabel,
        hintText: S.exporterGSSpreadsheetHint,
        helperText: S.exporterGSSpreadsheetHelper,
        helperMaxLines: 3,
        border: const OutlineInputBorder(),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffix: GestureDetector(
          onTap: () => setSheet(null),
          child: const Icon(KIcons.clear, size: 16.0),
        ),
      ),
    );
  }

  Future<void> setSheet(GoogleSpreadsheet? newSheet) {
    _idController.text = newSheet?.name ?? '';
    sheet = newSheet;
    return widget.onSheetChanged(newSheet);
  }

  @override
  void initState() {
    sheet = widget.sheet;
    _idController = TextEditingController(text: sheet?.name);
    super.initState();
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }
}

class _SheetNamer extends StatefulWidget {
  final String initialValue;

  final String label;

  final List<GoogleSheetProperties>? sheets;

  final List<List<GoogleSheetCellData>> Function() getSource;

  final List<GoogleSheetCellData> Function() getHeader;

  const _SheetNamer({
    Key? key,
    required this.initialValue,
    required this.label,
    required this.getSource,
    required this.getHeader,
    this.sheets,
  }) : super(key: key);

  @override
  State<_SheetNamer> createState() => _SheetNamerState();
}

class _SheetNamerState extends State<_SheetNamer> {
  Iterable<String>? autofillHints;

  late TextEditingController _controller;

  String? get name => _controller.text.isEmpty ? null : _controller.text;

  @override
  Widget build(BuildContext context) {
    final sheetName = S.exporterGSDefaultSheetName(widget.label);
    return TextField(
      controller: _controller,
      autofillHints: autofillHints,
      decoration: InputDecoration(
        labelText: S.exporterGSSheetLabel(sheetName),
        hintText: widget.initialValue,
        suffix: GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _SheetPreviewer(
                source: _SheetPreviewerDataTableSource(widget.getSource()),
                header: widget.getHeader(),
                title: S.exporterGSDefaultSheetName(widget.label),
              ),
            ),
          ),
          child: Tooltip(
            message: S.exporterGSPreviewerTitle(sheetName),
            child: const Icon(Icons.remove_red_eye_sharp),
          ),
        ),
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
      body: PaginatedDataTable(
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
        sortAscending: false,
        showCheckboxColumn: false,
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

class _GoogleUsedSheets {
  final String spreadsheetId;

  final int menuSheetId;
  final int stockSheetId;
  final int quantitiesSheetId;
  final int replenisherSheetId;
  final int customerSheetId;

  const _GoogleUsedSheets({
    required this.spreadsheetId,
    required this.menuSheetId,
    required this.stockSheetId,
    required this.quantitiesSheetId,
    required this.replenisherSheetId,
    required this.customerSheetId,
  });
}
