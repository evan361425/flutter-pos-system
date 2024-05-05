import 'package:possystem/models/repository.dart';
import 'package:possystem/services/storage.dart';

import '../model.dart';
import '../objects/menu_object.dart';
import '../repository/quantities.dart';
import '../stock/quantity.dart';
import 'product_ingredient.dart';

class ProductQuantity extends Model<ProductQuantityObject>
    with ModelStorage<ProductQuantityObject>, ModelSearchable<ProductQuantityObject> {
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
    super.id,
    super.status = ModelStatus.normal,
    super.name = '',
    Quantity? quantity,
    this.amount = 0,
    this.additionalCost = 0,
    this.additionalPrice = 0,
  }) {
    if (quantity != null) this.quantity = quantity;
  }

  factory ProductQuantity.fromObject(ProductQuantityObject object) {
    final quantity = Quantities.instance.getItem(object.quantityId!);
    if (quantity == null) {
      throw Exception(object.quantityId);
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
    var quantity =
        ori?.quantity ?? Quantities.instance.getItemByName(row[0]) ?? Quantities.instance.getStagedByName(row[0]);
    if (quantity == null) {
      quantity = Quantity(
        name: row[0],
        status: ModelStatus.staged,
      );
      Quantities.instance.addStaged(quantity);
    }

    final amount = row.length > 1 ? num.tryParse(row[1]) ?? 0 : 0;
    final ap = row.length > 2 ? num.tryParse(row[2]) ?? 0 : 0;
    final ac = row.length > 3 ? num.tryParse(row[3]) ?? 0 : 0;
    final status = ori == null
        ? ModelStatus.staged
        : (amount == ori.amount && ap == ori.additionalPrice && ac == ori.additionalCost
            ? ModelStatus.normal
            : ModelStatus.updated);

    return ProductQuantity(
      id: ori?.id,
      quantity: quantity,
      amount: amount,
      additionalPrice: ap,
      additionalCost: ac,
      status: status,
    );
  }

  @override
  String get name => quantity.name;

  @override
  String get prefix => '${ingredient.prefix}.quantities.$id';

  @override
  String get statusName {
    // When the ingredient is new, the product quantity
    // must also be new, so only need to output whether
    // it is a "new quantity type"
    if (ingredient.status == ModelStatus.staged) {
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
