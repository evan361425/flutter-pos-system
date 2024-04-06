import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/services/storage.dart';

class OrderAttributeOption extends Model<OrderAttributeOptionObject>
    with ModelStorage<OrderAttributeOptionObject>, ModelOrderable<OrderAttributeOptionObject> {
  /// Connect to parent model
  late OrderAttribute attribute;

  bool isDefault;

  num? modeValue;

  @override
  final Stores storageStore = Stores.orderAttributes;

  OrderAttributeOption({
    super.id,
    super.status = ModelStatus.normal,
    super.name = 'order attribute option',
    int index = 0,
    this.isDefault = false,
    this.modeValue,
  }) {
    this.index = index;
  }

  factory OrderAttributeOption.fromObject(OrderAttributeOptionObject object) {
    return OrderAttributeOption(
      id: object.id!,
      name: object.name!,
      index: object.index!,
      isDefault: object.isDefault!,
      modeValue: object.modeValue,
    );
  }

  factory OrderAttributeOption.fromRow(
    OrderAttributeOption? ori,
    List<String> row, {
    required int index,
  }) {
    final isDefault = row.length > 1 ? row[1] == 'true' : false;
    final modeValue = row.length > 2 ? num.tryParse(row[2]) : null;
    final status = ori == null
        ? ModelStatus.staged
        : (isDefault == ori.isDefault && modeValue == ori.modeValue ? ModelStatus.normal : ModelStatus.updated);

    return OrderAttributeOption(
      id: ori?.id,
      name: row[0],
      isDefault: isDefault,
      modeValue: modeValue,
      index: index,
      status: status,
    );
  }

  @override
  String get prefix => '${repository.prefix}.options.$id';

  @override
  OrderAttribute get repository => attribute;

  @override
  set repository(repo) => attribute = repo as OrderAttribute;

  OrderAttributeMode get mode => attribute.mode;

  /// Use [modeValue] to calculate correct final price in order.
  num calculatePrice(num price) {
    if (modeValue == null) return price;

    switch (attribute.mode) {
      case OrderAttributeMode.changeDiscount:
        return price * modeValue! / 100;
      case OrderAttributeMode.changePrice:
        return price + modeValue!;
      default:
        return price;
    }
  }

  @override
  OrderAttributeOptionObject toObject() => OrderAttributeOptionObject(
        id: id,
        name: name,
        index: index,
        isDefault: isDefault,
        modeValue: modeValue,
      );
}
