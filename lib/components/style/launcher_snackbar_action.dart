import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/launcher.dart';

class LauncherSnackbarAction extends SnackBarAction {
  LauncherSnackbarAction({
    Key? key,
    required String label,
    required String link,
    required String logCode,
  }) : super(
            key: key,
            label: label,
            onPressed: () {
              Log.ger('snackbar launch', logCode, link);
              Launcher.launch(link).ignore();
            });
}
