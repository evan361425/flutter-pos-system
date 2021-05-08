import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/services/database.dart';

class OrderHistory {
  static final OrderHistory _instance = OrderHistory._constructor();

  static OrderHistory get instance => _instance;

  OrderHistory._constructor();

  Future<num> getStashLength() {
    return Database.instance.length(Collections.order_stash);
  }

  Future<OrderObject> pop([remove = false]) async {
    final snapshot = await Database.instance.pop(
      Collections.order_history,
      remove,
    );
    return OrderObject.build(snapshot.data());
  }

  Future<OrderObject> popStash() async {
    final snapshot = await Database.instance.pop(Collections.order_stash);
    return OrderObject.build(snapshot.data());
  }

  Future<void> push(OrderObject order) {
    return Database.instance.push(Collections.order_history, order.toMap());
  }

  Future<void> stash(OrderObject order) {
    return Database.instance.push(Collections.order_stash, order.toMap());
  }
}
