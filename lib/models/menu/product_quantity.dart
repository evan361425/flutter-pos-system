import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/services/storage.dart';

import '../model.dart';
import '../objects/menu_object.dart';
import '../repository/quantities.dart';
import '../stock/quantity.dart';
import 'product_ingredient.dart';

class ProductQuantity extends Model<ProductQuantityObject>
    with
        ModelStorage<ProductQuantityObject>,
        ModelSearchable<ProductQuantityObject> {
  /// Connect to parent object
  late final ProductIngredient ingredient;

  /// Connect to stock.
  late Quantity quantity;

  /// Amount of ingredient per product
  num amount;

  /// finalCost = product.cost + additionalCost
  num additionalCost;

  /// finalPrice = product.price + additionPrice
  num additionalPrice;

  @override
  final Stores storageStore = Stores.menu;

  ProductQuantity({
    String? id,
    ModelStatus? status,
    Quantity? quantity,
    this.amount = 0,
    this.additionalCost = 0,
    this.additionalPrice = 0,
  }) : super(id, status) {
    if (quantity != null) this.quantity = quantity;
  }

  factory ProductQuantity.fromObject(ProductQuantityObject object) {
    final quantity = Quantities.instance.getItem(object.quantityId!);
    if (quantity == null) {
      info(object.quantityId!, 'menu.parse.error.quantity');
      throw Error();
    }

    return ProductQuantity(
      id: object.id,
      quantity: quantity,
      amount: object.amount!,
      additionalCost: object.additionalCost!,
      additionalPrice: object.additionalPrice!,
    );
  }

  factory ProductQuantity.fromRow(
    ProductQuantity? ori,
    List<String> row,
  ) {
    final status = ori == null ? ModelStatus.staged : ModelStatus.updated;
    var quantity = ori?.quantity ?? Quantities.instance.getItemByName(row[0]);

    if (quantity == null) {
      quantity = Quantity(
        name: row[0],
        status: ModelStatus.staged,
      );
      Quantities.instance.addStaged(quantity);
    }

    num checkAndParse(int index) {
      return row.length > index ? num.tryParse(row[index]) ?? 0 : 0;
    }

    return ProductQuantity(
      id: ori?.id,
      quantity: quantity,
      amount: checkAndParse(1),
      additionalPrice: checkAndParse(2),
      additionalCost: checkAndParse(3),
      status: status,
    );
  }

  @override
  String get name => quantity.name;

  @override
  String get prefix => '${ingredient.prefix}.quantities.$id';

  @override
  String get statusName {
    // 當產品是新的，代表產品份量一定也是新的，這樣就只需要輸出是否為「新的份量種類」
    if (ingredient.product.status == ModelStatus.staged) {
      return quantity.status == ModelStatus.staged ? 'stagedQua' : 'normal';
    }

    return super.statusName;
  }

  @override
  ProductIngredient get repository => ingredient;

  @override
  set repository(Repository repo) => ingredient = repo as ProductIngredient;

  @override
  ProductQuantityObject toObject() => ProductQuantityObject(
        id: id,
        quantityId: quantity.id,
        amount: amount,
        additionalCost: additionalCost,
        additionalPrice: additionalPrice,
      );
}
