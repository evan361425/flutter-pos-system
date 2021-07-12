import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Translator {
  static final Translator instance = Translator._constructor();

  Map<String, String> data = {};

  //This is the static member for allowing simple access to the delegate
  // from the MaterialApp
  Translator._constructor();

  Future<void> load(Locale locale) async {
    final fileName = 'lang/$locale/app.g.json';
    final contents = await rootBundle.loadString(fileName);
    final Map<String, dynamic> loaded = jsonDecode(contents);
    data = loaded.cast<String, String>();
  }

  String translate(String key, Map<String, Object> kvargs) {
    if (data[key] == null) {
      key = key.split('.').last;
      kvargs.forEach((k, v) => key += '-$v');
      return key;
    }

    var string = data[key]!;

    kvargs.forEach((key, value) {
      string = string.replaceAll('{$key}', value.toString());
    });

    return string;
  }
}

String tt(String key, [Map<String, Object>? kvargs]) {
  return Translator.instance.translate(key, kvargs ?? {});
}
