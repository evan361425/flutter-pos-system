import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as l;
import 'package:url_launcher/url_launcher_string.dart';

class Launcher {
  @visibleForTesting
  static late String lastUrl;

  static Future<bool> launch(String url) {
    assert(() {
      lastUrl = url;
      return true;
    }());
    return l.launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
