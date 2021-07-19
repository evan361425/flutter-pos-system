class CashierUnitObject {
  final num unit;

  int count;

  CashierUnitObject({required this.unit, required this.count});

  factory CashierUnitObject.fromMap(Map<String, num> map) {
    return CashierUnitObject(
      unit: map['unit'] ?? 0,
      count: map['count']?.toInt() ?? 0,
    );
  }

  Map<String, num> toMap() {
    return {'unit': unit, 'count': count};
  }
}

class CashierChangeBatchObject {
  CashierChangeEntryObject source;

  List<CashierChangeEntryObject> targets;

  CashierChangeBatchObject({required this.source, required this.targets});

  Map<String, Map<num, int>> toMap() {
    return {
      'source': {source.unit!: source.count!},
      'targets': {for (var target in targets) target.unit!: target.count!},
    };
  }

  factory CashierChangeBatchObject.fromMap(Map<String, Map<num, int>> map) {
    final source = map['source']?.entries.first;
    final targets = map['targets']?.entries ?? <MapEntry<num, int>>[];

    return CashierChangeBatchObject(
        source: CashierChangeEntryObject(
          count: source?.value,
          unit: source?.key,
        ),
        targets: [
          for (var target in targets)
            CashierChangeEntryObject(
              count: target.value,
              unit: target.key,
            )
        ]);
  }
}

class CashierChangeEntryObject {
  num? unit;

  int? count;

  CashierChangeEntryObject({this.unit, this.count});

  num get total {
    return isEmpty ? 0 : unit! * count!;
  }

  bool get isEmpty => unit == null || count == null;
}
