class CashierChangeBatchObject {
  CashierChangeEntryObject source;

  List<CashierChangeEntryObject> targets;

  CashierChangeBatchObject({required this.source, required this.targets});

  /// Build [CashierChangeBatchObject] by map.
  ///
  /// Throws an [AssertionError] if missing source and targets.
  /// Throws a [FormatException] if key cannot parse to num.
  factory CashierChangeBatchObject.fromMap(Map<String, Object?> map) {
    assert(map['source'] is Map && map['targets'] is Map);
    final source = (map['source'] as Map).entries.first;
    final targets = (map['targets'] as Map).entries;

    return CashierChangeBatchObject(
        source: CashierChangeEntryObject(
          count: source.value,
          unit: num.parse(source.key),
        ),
        targets: [
          for (var target in targets)
            CashierChangeEntryObject(
              count: target.value,
              unit: num.parse(target.key),
            )
        ]);
  }

  Map<String, Map<String, int>> toMap() {
    return {
      'source': {source.unit.toString(): source.count!},
      'targets': {
        for (var target in targets) target.unit.toString(): target.count!
      },
    };
  }

  @override
  String toString() {
    final t = targets.map((e) => '${e.unit} (${e.count})').join(', ');
    return '${source.unit} (${source.count}) => [$t]';
  }
}

class CashierChangeEntryObject {
  num? unit;

  int? count;

  CashierChangeEntryObject({this.unit, this.count});

  bool get isEmpty => unit == null || count == null;

  num get total {
    return isEmpty ? 0 : unit! * count!;
  }
}

class CashierUnitObject {
  final num unit;

  int count;

  CashierUnitObject({required this.unit, required this.count});

  factory CashierUnitObject.fromMap(Map<String, num> map) {
    final unit = map['unit'];
    assert(unit != null && unit != 0);

    return CashierUnitObject(
      unit: unit!,
      count: map['count']?.toInt() ?? 0,
    );
  }

  num get total => unit * count;

  Map<String, num> toMap() {
    return {'unit': unit, 'count': count};
  }
}
