import 'package:flutter/material.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/services/storage.dart';

import '../repository.dart';

class StockModel extends ChangeNotifier
    with
        Repository<IngredientModel>,
        InitilizableRepository,
        SearchableRepository {
  static late StockModel instance;

  StockModel() {
    initialize();

    StockModel.instance = this;
  }

  @override
  String get childCode => 'stock.ingredient.';

  @override
  Stores get storageStore => Stores.stock;

  String? get updatedDate {
    if (isEmpty) return null;

    DateTime? lastest;
    childs.forEach((element) {
      if (lastest == null) {
        lastest = element.updatedAt;
      } else if (element.updatedAt?.isAfter(lastest!) == true) {
        lastest = element.updatedAt;
      }
    });

    return Util.timeToDate(lastest);
  }

  Future<void> applyAmounts(Map<String, num> amounts) {
    final updateData = <String, Object>{};

    amounts.forEach((id, amount) {
      if (amount != 0) {
        final child = getChild(id);
        if (child != null) {
          updateData.addAll(child.updateInfo(amount));
        }
      }
    });

    if (updateData.isEmpty) return Future.value();

    notifyListeners();

    return Storage.instance.set(Stores.stock, updateData);
  }

  @override
  IngredientModel buildModel(String id, Map<String, Object> value) {
    return IngredientModel.fromObject(
      IngredientObject.build({
        'id': id,
        ...value,
      }),
    );
  }

  /// [oldData] is helpful when reverting order
  Future<void> order(OrderObject data, {OrderObject? oldData}) async {
    final amounts = <String, num>{};

    data.products.forEach((product) {
      product.ingredients.forEach((id, ingredient) {
        amounts[id] = (amounts[id] ?? 0) - ingredient.amount;
      });
    });

    // if we need to update order, need to revert stock status
    oldData?.products.forEach((product) {
      product.ingredients.forEach((id, ingredient) {
        amounts[id] = (amounts[id] ?? 0) + ingredient.amount;
      });
    });

    return applyAmounts(amounts);
  }
}
