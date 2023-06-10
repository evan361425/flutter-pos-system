import 'package:flutter/material.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/translator.dart';

class SheetNamer extends StatefulWidget {
  final String initialValue;

  final String label;

  final String? labelText;

  final bool? initialChecked;

  final List<GoogleSheetProperties>? sheets;

  const SheetNamer({
    Key? key,
    required this.initialValue,
    required this.label,
    this.initialChecked,
    this.labelText,
    this.sheets,
  }) : super(key: key);

  @override
  State<SheetNamer> createState() => SheetNamerState();

  String getLabelText() {
    return S.exporterGSSheetLabel(
      labelText ?? S.exporterGSDefaultSheetName(label),
    );
  }
}

class SheetNamerState extends State<SheetNamer> {
  Iterable<String>? autofillHints;

  late TextEditingController _controller;

  bool? checked;

  String? get name => _controller.text.isEmpty ? null : _controller.text;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: Key('gs_export.${widget.label}.sheet_namer'),
      controller: _controller,
      autofillHints: autofillHints,
      decoration: InputDecoration(
        prefix: checked == null
            ? null
            : SizedBox(
                height: 14,
                child: Checkbox(
                  key: Key('gs_export.${widget.label}.checkbox'),
                  value: checked,
                  visualDensity: VisualDensity.compact,
                  splashRadius: 0,
                  onChanged: (newValue) => setState(() => checked = newValue!),
                ),
              ),
        labelText: widget.getLabelText(),
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
