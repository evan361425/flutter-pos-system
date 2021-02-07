import 'package:flutter/material.dart';
import 'package:possystem/localizations.dart';

class TextSnackBar {
  static void success(BuildContext context) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(Local.of(context).t('success')),
      ),
    );
  }

  static void failed(BuildContext context) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(Local.of(context).t('failed')),
      ),
    );
  }
}
