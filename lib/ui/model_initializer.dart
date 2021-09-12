import 'package:flutter/material.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:provider/provider.dart';

import 'splash/welcome_splash.dart';

class ModelIntializer extends StatelessWidget {
  static bool _isReady = false;

  final Widget child;

  const ModelIntializer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isReady(context) ? child : WelcomeSplash();
  }

  bool isReady(BuildContext context) {
    if (_isReady) return true;

    final menu = context.watch<Menu>();
    final stock = context.watch<Stock>();
    final quantities = context.watch<Quantities>();
    final settings = context.watch<CustomerSettings>();
    if (!menu.isReady ||
        !stock.isReady ||
        !quantities.isReady ||
        !settings.isReady) {
      return false;
    }

    menu.items.forEach((catalog) {
      catalog.items.forEach((product) {
        product.items.forEach((ingredient) {
          // Although it should always be searchable, still make null handler
          // to avoid not found one and kill all others
          final ing = stock.getItem(ingredient.storageIngredientId!);
          if (ing != null) ingredient.ingredient = ing;

          ingredient.items.forEach((quantity) {
            final qua = quantities.getItem(quantity.storageQuantityId!);
            if (qua != null) quantity.quantity = qua;
          });
        });
      });
    });

    _isReady = true;
    return true;
  }
}
