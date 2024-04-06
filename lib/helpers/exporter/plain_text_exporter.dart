import 'package:flutter/services.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/helpers/formatter/plain_text_formatter.dart';

import 'data_exporter.dart';

class PlainTextExporter extends DataExporter {
  final PlainTextFormatter formatter;

  const PlainTextExporter({this.formatter = const PlainTextFormatter()});

  Future<void> export(Formattable able) {
    final text = formatter.getRows(able).map((row) => row.join('\n')).join('\n\n');
    return exportToClipboard(text);
  }

  Future<void> exportToClipboard(String text) {
    return Clipboard.setData(ClipboardData(text: text));
  }
}
