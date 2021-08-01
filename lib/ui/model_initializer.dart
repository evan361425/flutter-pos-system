import 'package:flutter/material.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/ui/splash/welcome_splash.dart';
import 'package:provider/provider.dart';

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
    if (!menu.isReady || !stock.isReady || !quantities.isReady) {
      return false;
    }

    menu.items.forEach((catalog) {
      catalog.items.forEach((product) {
        product.items.forEach((ingredient) {
          ingredient.setIngredient(stock.getItem(ingredient.id)!);
          ingredient.items.forEach((quantity) {
            quantity.setQuantity(quantities.getItem(quantity.id)!);
          });
        });
      });
    });

    _isReady = true;
    return true;
  }
}
