import 'package:flutter/material.dart';
import 'package:possystem/translator.dart';
import 'package:upgrader/upgrader.dart' as upgrader;

class UpgradeAlert extends StatelessWidget {
  final Widget child;

  const UpgradeAlert({required this.child});

  @override
  Widget build(BuildContext context) {
    return upgrader.UpgradeAlert(
      appcastConfig: upgrader.AppcastConfiguration(
        url:
            'https://raw.githubusercontent.com/evan361425/flutter-pos-system/master/appcast.xml',
        supportedOS: const ['android'],
      ),
      showReleaseNotes: false,
      durationToAlertAgain: const Duration(days: 1),
      messages: _CustomUpgraderMessages(),
      child: child,
    );
  }
}

class _CustomUpgraderMessages extends upgrader.UpgraderMessages {
  _CustomUpgraderMessages() : super(code: 'fake');

  @override
  String? message(upgrader.UpgraderMessage messageKey) {
    switch (messageKey) {
      case upgrader.UpgraderMessage.title:
        return tt('home.upgrader.title');
      case upgrader.UpgraderMessage.body:
        return tt('home.upgrader.body');
      case upgrader.UpgraderMessage.buttonTitleIgnore:
        return tt('home.upgrader.ignore');
      case upgrader.UpgraderMessage.buttonTitleUpdate:
        return tt('home.upgrader.confirm');
      case upgrader.UpgraderMessage.buttonTitleLater:
        return tt('home.upgrader.later');
      default:
        return '';
    }
  }
}
