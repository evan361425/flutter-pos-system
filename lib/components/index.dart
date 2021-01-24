import 'package:flutter/material.dart';
import 'package:possystem/app_localizations.dart';

class Component {
  BuildContext context;
  Component(this.context);

  Widget text(String text) {
    return Center(
      child: Text(
        AppLocalizations.of(context).t(text),
        style: Theme.of(context).textTheme.button,
      ),
    );
  }

  Widget spinner() {
    return Center(
      child: CircularProgressIndicator()
    );
  }
}