import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart' as upgrader;

class UpgradeAlert extends StatelessWidget {
  const UpgradeAlert({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return upgrader.UpgradeAlert(
      appcastConfig: upgrader.AppcastConfiguration(
        url:
            'https://raw.githubusercontent.com/evan361425/flutter-pos-system/master/appcast.xml',
        supportedOS: const ['android'],
      ),
      showLater: false,
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
      case upgrader.UpgraderMessage.body:
        return '版本 {{currentAppStoreVersion}} 已經釋出拉，快來試試看新版本吧！';
      case upgrader.UpgraderMessage.buttonTitleIgnore:
        return '先不要';
      case upgrader.UpgraderMessage.buttonTitleUpdate:
        return '立即前往';
      case upgrader.UpgraderMessage.title:
        return '有新版本囉';
      default:
    }
    return '';
  }
}
