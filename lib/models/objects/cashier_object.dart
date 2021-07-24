class CashierChangeBatchObject {
  CashierChangeEntryObject source;

  List<CashierChangeEntryObject> targets;

  CashierChangeBatchObject({required this.source, required this.targets});

  factory CashierChangeBatchObject.fromMap(Map<String, Object?> map) {
    return CashierChangeBatchObject(
        source:
            CashierChangeEntryObject.fromMap(map['source'] as Map<String, num>),
        targets: [
          for (var target in map['targets'] as Iterable)
            CashierChangeEntryObject.fromMap(target as Map<String, num>)
        ]);
  }

  Map<String, Object> toMap() {
    return {
      'source': source.toMap(),
      'targets': [for (var target in targets) target.toMap()],
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

  factory CashierChangeEntryObject.fromMap(Map<String, num> map) {
    return CashierChangeEntryObject(
      count: map['count']?.toInt() ?? 0,
      unit: map['unit'],
    );
  }

  bool get isEmpty => unit == null || count == null;

  num get total {
    return isEmpty ? 0 : unit! * count!;
  }

  Map<String, num> toMap() {
    return {
      'unit': unit!,
      'count': count!,
    };
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
