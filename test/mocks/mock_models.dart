import 'package:mockito/annotations.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/customer/customer_setting_option.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/order/order_ingredient.dart';
import 'package:possystem/models/order/order_product.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/models/stock/replenishment.dart';

@GenerateMocks([
  Catalog,
  CustomerSetting,
  CustomerSettingOption,
  Ingredient,
  OrderIngredient,
  OrderIngredientObject,
  OrderObject,
  OrderProduct,
  OrderProductObject,
  ProductIngredient,
  Product,
  ProductQuantity,
  ProductQuantityObject,
  Quantity,
  Replenishment,
])
void main() {}
