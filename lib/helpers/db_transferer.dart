class DBTransferer {
  static String toCombination(Map<Object, Object> data) {
    return ',' +
        data.entries
            .map<String>((entry) => '${entry.key}:${entry.value}')
            .join(',') +
        ',';
  }

  static Map<String, String> parseCombination(String? value) {
    value = value ?? '';
    return {
      for (final item in value
          .split(',')
          .where((e) => e.isNotEmpty)
          .map((e) => e.split(':')))
        item[0]: item[1]
    };
  }
}
