import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/services/storage.dart';

class OrderAttribute extends Model<OrderAttributeObject>
    with
        ModelOrderable<OrderAttributeObject>,
        ModelStorage<OrderAttributeObject>,
        Repository<OrderAttributeOption>,
        RepositoryStorage<OrderAttributeOption>,
        RepositoryOrderable<OrderAttributeOption> {
  OrderAttributeMode mode;

  @override
  final RepositoryStorageType repoType = RepositoryStorageType.repoModel;

  @override
  final Stores storageStore = Stores.orderAttributes;

  OrderAttribute({
    String? id,
    ModelStatus? status,
    String name = 'order attribute',
    int index = 0,
    this.mode = OrderAttributeMode.statOnly,
    Map<String, OrderAttributeOption>? options,
  }) : super(id, status) {
    this.name = name;
    this.index = index;
    if (options != null) replaceItems(options);
  }

  factory OrderAttribute.fromObject(OrderAttributeObject object) {
    return OrderAttribute(
        id: object.id,
        name: object.name!,
        index: object.index!,
        mode: object.mode!,
        options: {
          for (var option in object.options)
            option.id!: OrderAttributeOption.fromObject(option)
        })
      ..prepareItem();
  }

  factory OrderAttribute.fromRow(
    OrderAttribute? ori,
    List<String> row, {
    required int index,
    required OrderAttributeMode mode,
  }) {
    final status = ori == null
        ? ModelStatus.staged
        : (mode == ori.mode ? ModelStatus.normal : ModelStatus.updated);

    return OrderAttribute(
      id: ori?.id,
      name: row[0],
      index: index,
      mode: mode,
      status: status,
    );
  }

  OrderAttributeOption? get defaultOption {
    try {
      return items.firstWhere((option) => option.isDefault);
    } catch (e) {
      return null;
    }
  }

  @override
  OrderAttributes get repository => OrderAttributes.instance;

  @override
  set repository(repo) {}

  bool get shouldHaveModeValue => mode != OrderAttributeMode.statOnly;

  @override
  OrderAttributeOption buildItem(String id, Map<String, Object?> value) {
    throw UnimplementedError();
  }

  Future<void> clearDefault() async {
    final option = defaultOption;

    if (option != null) {
      await option.update(OrderAttributeOptionObject(
        isDefault: false,
        // null is settable, should specify the value here
        modeValue: option.modeValue,
      ));
    }
  }

  @override
  OrderAttributeObject toObject() => OrderAttributeObject(
        id: id,
        name: name,
        index: index,
        mode: mode,
        options: items.map((e) => e.toObject()),
      );
}
