import 'package:build/build.dart';
import 'package:yaml/yaml.dart';

Builder buildLanguage(BuilderOptions options) {
  return LanguageBuilder();
}

class LanguageBuilder implements Builder {
  static final Map<String, Map<String, String>> result = {};

  @override
  final buildExtensions = const {
    '.yaml': ['.json']
  };

  Map<String, String> current = {};

  @override
  Future<void> build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;
    current.clear();

    final language = parseLanguage(inputId.path);
    final filename = inputId.pathSegments.last.split('.').first;
    final prefix = filename == 'app' ? '' : '$filename.';

    final contents = await buildStep.readAsString(inputId);
    final yaml = loadYaml(contents);
    _loadYamlRecursivly(prefix, yaml);

    result[language] = current;
  }

  void _loadYamlRecursivly(String prefix, YamlMap data) {
    data.forEach((key, value) {
      if (value is YamlMap) {
        _loadYamlRecursivly('$prefix$key.', value);
      } else {
        current[prefix + key] = value.toString();
      }
    });
  }

  static String parseLanguage(String source) {
    final segments = source.split('/');
    segments.removeLast();
    return segments.last;
  }
}
