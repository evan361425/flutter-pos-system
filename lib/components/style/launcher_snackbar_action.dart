import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/launcher.dart';

class LauncherSnackbarAction extends SnackBarAction {
  LauncherSnackbarAction({
    super.key,
    required super.label,
    required String link,
    required String logCode,
  }) : super(onPressed: () {
          Log.ger('snackbar launch', logCode, link);
          Launcher.launch(link).ignore();
        });
}
