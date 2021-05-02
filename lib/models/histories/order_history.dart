import 'package:possystem/models/maps/order_map.dart';
import 'package:possystem/services/database.dart';

class OrderHistory {
  static final OrderHistory _instance = OrderHistory._constructor();

  static OrderHistory get instance => _instance;

  OrderHistory._constructor();

  void push(OrderMap order) {
    Database.instance.push(Collections.order_history, order.output());
  }

  Future<OrderMap> pop([remove = false]) async {
    final snapshot = await Database.instance.pop(
      Collections.order_history,
      remove,
    );
    return OrderMap.build(snapshot.data());
  }

  void stash(OrderMap order) {
    Database.instance.push(Collections.order_stash, order.output());
  }

  Future<OrderMap> popStash() async {
    final snapshot = await Database.instance.pop(Collections.order_stash);
    return OrderMap.build(snapshot.data());
  }

  Future<num> getStashLength() {
    return Database.instance.length(Collections.order_stash);
  }
}
