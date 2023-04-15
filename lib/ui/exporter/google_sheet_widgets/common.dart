import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/single_text_dialog.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/translator.dart';

const exporterCacheKey = 'exporter_google_sheet';
const importerCacheKey = 'importer_google_sheet';
const errorCodeRefresh = 'gs_refresh_failed';
const errorCodeImport = 'gs_import_failed';
const errorCodeExport = 'gs_export_failed';
const errorCodeSelect = 'gs_select_failed';

Future<GoogleSpreadsheet?> selectSpreadsheet(
  BuildContext context,
  GoogleSpreadsheet? origin,
  GoogleSheetExporter exporter,
) async {
  const idRegex = r'^([a-zA-Z0-9-_]{15,})$';
  const urlRegex = r'/spreadsheets/d/([a-zA-Z0-9-_]{15,})/';

  String? validator(String? text) {
    if (text == null || text.isEmpty) return '不能為空';

    if (!RegExp(urlRegex).hasMatch(text)) {
      if (!RegExp(idRegex).hasMatch(text)) {
        return '不合法的文字，必須包含：\n'
            '/spreadsheets/d/<ID>/\n'
            '或者直接給 ID（英文+數字+底線+減號的組合）';
      }
    }

    return null;
  }

  /// [_validator] make sure [text] is not null
  String? formatter(String? text) {
    final urlResult = RegExp(urlRegex).firstMatch(text!);

    if (urlResult != null) {
      return urlResult.group(1);
    }

    return RegExp(idRegex).firstMatch(text)?.group(0);
  }

  final id = await showDialog<String>(
    context: context,
    builder: (context) {
      return SingleTextDialog(
        header: CachedNetworkImage(
          imageUrl:
              "https://raw.githubusercontent.com/evan361425/flutter-pos-system/master/assets/web/tutorial-gs-copy-url.gif",
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              CircularProgressIndicator(value: downloadProgress.progress),
        ),
        initialValue: origin?.id,
        decoration: InputDecoration(
          labelText: S.exporterGSSpreadsheetLabel,
          helperText: origin?.name == null
              ? '輸入試算表網址或試算表 ID'
              : '該試算表名稱為「${origin?.name}」',
          floatingLabelBehavior: FloatingLabelBehavior.always,
          errorMaxLines: 5,
        ),
        autofocus: false,
        selectAll: true,
        validator: validator,
        formatter: formatter,
      );
    },
  );

  if (id == null) return null;

  final result = await exporter.getSpreadsheet(id);
  if (result == null) {
    if (context.mounted) {
      showSnackBar(context, '找不到該表單，是否沒開放權限讀取？');
    }
  }
  return result;
}
