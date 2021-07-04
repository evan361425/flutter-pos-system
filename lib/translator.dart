import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Translator {
  static final Translator instance = Translator._constructor();

  Map<String, String> _data = {};

  //This is the static member for allowing simple access to the delegate
  // from the MaterialApp
  Translator._constructor();

  Future<void> load(Locale locale) async {
    final fileName = 'lang/$locale/app.g.json';
    final contents = await rootBundle.loadString(fileName);
    final Map<String, dynamic> data = jsonDecode(contents);
    _data = data.cast<String, String>();
  }

  String translate(String key, Map<String, String> kvargs) {
    var value = _data[key] ?? key;

    kvargs.forEach((key, value) {
      value = value.replaceAll('{$key}', value);
    });

    return value;
  }
}

String tt(String key, [Map<String, String>? kvargs]) {
  return Translator.instance.translate(key, kvargs ?? {});
}
