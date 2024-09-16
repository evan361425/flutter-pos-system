import 'package:flutter/material.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/translator.dart';

class SheetSelector extends StatefulWidget {
  final GoogleSheetProperties? defaultValue;

  final String label;

  const SheetSelector({
    super.key,
    this.defaultValue,
    required this.label,
  });

  @override
  State<SheetSelector> createState() => SheetSelectorState();
}

class SheetSelectorState extends State<SheetSelector> {
  late List<GoogleSheetProperties> sheets;

  GoogleSheetProperties? selected;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<GoogleSheetProperties?>(
      key: Key('gs_export.${widget.label}.sheet_selector'),
      value: selected,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        label: Text(S.transitGSSheetNameLabel(S.transitModelName(widget.label))),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      onChanged: (newSelected) => setState(() => selected = newSelected),
      items: [
        DropdownMenuItem<GoogleSheetProperties?>(
          value: null,
          child: Text(
            S.transitGSSpreadsheetImportDropdownHint,
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
        ),
        for (var sheet in sheets)
          DropdownMenuItem<GoogleSheetProperties?>(
            value: sheet,
            child: Text(sheet.title),
          ),
      ],
    );
  }

  setSheets(List<GoogleSheetProperties> newSheets) {
    setState(() {
      if (!newSheets.contains(selected)) {
        selected = null;
      }
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
