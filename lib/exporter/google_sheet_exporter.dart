import 'package:file_picker/file_picker.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/services/auth.dart';

class GoogleSheetExporter {
  bool _setUp = false;

  late SheetsApi sheetsApi;

  late DriveApi driveApi;

  Future<bool> setApiClient() async {
    if (_setUp) {
      return true;
    }

    if (await Auth.instance.loginIfNot()) {
      final client = await Auth.instance.getAuthenticatedClient(
        scopes: [
          SheetsApi.spreadsheetsScope,
          DriveApi.driveMetadataReadonlyScope,
        ],
      );

      if (client != null) {
        sheetsApi = SheetsApi(client);
        driveApi = DriveApi(client);
        _setUp = true;
      }
    }

    return _setUp;
  }

  Future<String?> pickSheets() async {
    if (!await setApiClient()) {
      return null;
    }

    final picked = await FilePicker.platform.pickFiles(withReadStream: true);
    if (picked == null || picked.files.isEmpty) {
      return null;
    }

    final pickedName = Util.removeExtension(picked.files.first.name);
    debug(pickedName, 'pick_sheet.name');
    final drive = await driveApi.files.list(
      q: "mimeType = 'application/vnd.google-apps.spreadsheet' and name = '$pickedName' and trashed = false",
      $fields: 'files(id)',
    );
    if (drive.files?.isEmpty != false) {
      debug('not found', 'pick_sheet.search');
      return null;
    }

    final id = drive.files!.first.id;
    if (id == null) {
      return null;
    }

    info(id, 'pick_sheet.id');
    return id;
  }
}

class GoogleSheet {
  final String fileName;
  final String sheetName;

  GoogleSheet({
    required this.fileName,
    required this.sheetName,
  });
}
