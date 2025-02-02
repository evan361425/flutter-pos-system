import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/responsive_dialog.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/widgets.dart';

class SheetPreviewPage extends StatelessWidget {
  final ModelDataTableSource source;

  final String title;

  final List<CellData> header;

  final Widget? action;

  const SheetPreviewPage({
    super.key,
    required this.source,
    required this.title,
    required this.header,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialog(
      title: Text(title),
      action: action,
      fixedSizeOnDialog: const Size(800, 0),
      scrollable: false,
      content: SingleChildScrollView(
        child: Column(children: [
          ModelDataTable(
            headers: header.map((e) => e.toString()).toList(),
            notes: header.map((e) => e.note).toList(),
            source: source,
          ),
          const SizedBox(height: kFABSpacing),
        ]),
      ),
    );
  }
}
