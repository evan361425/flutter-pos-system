import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/stock_batch_repo.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/services/storage.dart';

class StockBatchModel extends NotifyModel {
  String name;

  /// ingredient id => add number
  final Map<String, num> data;

  StockBatchModel({
    required this.name,
    String? id,
    Map<String, num>? data,
  })  : data = data ?? {},
        super(id);

  factory StockBatchModel.fromObject(StockBatchObject object) =>
      StockBatchModel(
        id: object.id,
        name: object.name,
        data: object.data,
      );

  @override
  String get code => 'stock.batch';

  @override
  Stores get storageStore => Stores.stock_batch;

  void apply() => StockModel.instance.applyAmounts(data);

  num? getNumOfId(String id) => data[id];

  @override
  void removeFromRepo() {
    StockBatchRepo.instance.removeItem(id);
  }

  @override
  StockBatchObject toObject() => StockBatchObject(
        id: id,
        name: name,
        data: data,
      );

  @override
  String toString() => name;
}
