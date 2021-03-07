import 'package:flutter/material.dart';
import 'package:possystem/localizations.dart';

class TextSnackBar {
  static void success(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(Local.of(context).t('success')),
      ),
    );
  }

  static void failed(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(Local.of(context).t('failed')),
      ),
    );
  }
}
