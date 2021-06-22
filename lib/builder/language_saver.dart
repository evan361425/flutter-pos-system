import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:possystem/builder/language_builder.dart';

Builder buildSaver(BuilderOptions options) {
  return LanguageSaver();
}

class LanguageSaver implements Builder {
  @override
  final buildExtensions = const {
    '.yaml': ['.g.json']
  };

  @override
  FutureOr<void> build(BuildStep buildStep) {
    final inputId = buildStep.inputId;
    final language = LanguageBuilder.parseLanguage(inputId.path);
    final targetId = inputId.changeExtension('.g.json');

    buildStep.writeAsString(
        targetId, jsonEncode(LanguageBuilder.result[language]));
  }
}
