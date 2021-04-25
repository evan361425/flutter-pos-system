import 'package:possystem/models/order/order_product_model.dart';
import 'package:possystem/services/database.dart';

class OrderHistory {
  static final OrderHistory _instance = OrderHistory._constructor();

  static OrderHistory get instance => _instance;

  OrderHistory._constructor();

  void add(Map<String, dynamic> data) {
    final key = DateTime.now().millisecondsSinceEpoch.toString();

    Database.instance.update(Collections.order_history, {
      key: data,
    });
  }
}
