import 'package:flutter/services.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/formatter/plain_text_formatter.dart';

import 'data_exporter.dart';

class PlainTextExporter extends DataExporter {
  const PlainTextExporter();

  Future<void> export(FormattableModel able) {
    final rows = findPlainTextFormatter(able).getRows();
    final text = rows.map((row) => row.join('\n')).join('\n\n');

    return exportToClipboard(text);
  }

  Future<void> exportToClipboard(String text) {
    return Clipboard.setData(ClipboardData(text: text));
  }
}
