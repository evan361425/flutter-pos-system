import 'package:mockito/annotations.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/order/order_ingredient_model.dart';
import 'package:possystem/models/order/order_product_model.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/models/stock/stock_batch_model.dart';

@GenerateMocks([
  CatalogModel,
  IngredientModel,
  OrderIngredientModel,
  OrderIngredientObject,
  OrderObject,
  OrderProductModel,
  OrderProductObject,
  ProductIngredientModel,
  ProductModel,
  ProductQuantityModel,
  ProductQuantityObject,
  QuantityModel,
  StockBatchModel,
])
void main() {}
