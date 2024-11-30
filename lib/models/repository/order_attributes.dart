import 'package:flutter/foundation.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/services/storage.dart';

import '../repository.dart';

class OrderAttributes extends ChangeNotifier
    with Repository<OrderAttribute>, RepositoryOrderable<OrderAttribute>, RepositoryStorage<OrderAttribute> {
  static late OrderAttributes instance;

  @override
  final Stores storageStore = Stores.orderAttributes;

  OrderAttributes() {
    instance = this;
  }

  List<OrderAttribute> get notEmptyItems => itemList.where((item) => item.isNotEmpty).toList();

  @override
  OrderAttribute buildItem(String id, Map<String, Object?> value) {
    return OrderAttribute.fromObject(OrderAttributeObject.build({
      'id': id,
      ...value,
    }));
  }
}
