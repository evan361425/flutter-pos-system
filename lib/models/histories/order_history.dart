import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/services/database.dart';

class OrderHistory {
  static final OrderHistory _instance = OrderHistory._constructor();

  static OrderHistory get instance => _instance;

  OrderHistory._constructor();

  void push(OrderObject order) {
    Database.instance.push(Collections.order_history, order.toMap());
  }

  Future<OrderObject> pop([remove = false]) async {
    final snapshot = await Database.instance.pop(
      Collections.order_history,
      remove,
    );
    return OrderObject.build(snapshot.data());
  }

  void stash(OrderObject order) {
    Database.instance.push(Collections.order_stash, order.toMap());
  }

  Future<OrderObject> popStash() async {
    final snapshot = await Database.instance.pop(Collections.order_stash);
    return OrderObject.build(snapshot.data());
  }

  Future<num> getStashLength() {
    return Database.instance.length(Collections.order_stash);
  }
}
