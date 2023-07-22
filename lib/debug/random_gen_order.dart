import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:provider/provider.dart';

List<OrderObject> generateOrder({
  required int orderCount,
  required DateTime startFrom,
  required DateTime endTo,
}) {
  final rng = Random();
  final products = Menu.instance.items
      .map((catalog) => catalog.items)
      .expand((e) => e)
      .toList();
  final productCount = products.length;
  final result = <OrderObject>[];

  final interval = endTo.difference(startFrom).inMinutes;
  if (interval == 0 || productCount == 0) return const [];

  final createdList = [
    for (var i = 0; i < orderCount; i++) rng.nextInt(interval)
  ]..sort();

  OrderSelectedAttributeObject generateAttr(OrderAttribute attr) {
    final optIdx = rng.nextInt(attr.length + 1);
    if (optIdx == attr.length) return const OrderSelectedAttributeObject();

    final opt = attr.itemList[optIdx];
    return OrderSelectedAttributeObject(
      name: attr.name,
      optionName: opt.name,
      mode: attr.mode,
      modeValue: opt.modeValue,
    );
  }

  while (orderCount-- > 0) {
    final ordered = <OrderProductObject>[];
    // 1~10
    var round = rng.nextInt(10) + 1;
    while (round-- != 0) {
      // random choose product
      final product = products[rng.nextInt(productCount)];

      // if already ordered that product, possibly increment the count
      final possible = _selectExistedProduct(ordered, product.id);
      if (possible.isNotEmpty && rng.nextBool()) {
        final idx = possible[rng.nextInt(possible.length)];
        final map = ordered[idx].toMap();
        map['count'] = (map['count'] as int) + 1;
        ordered[idx] = OrderProductObject.fromMap(map);
      } else {
        // whether use ingredient?
        final v = product.itemList;
        final i = v.isEmpty || rng.nextBool() ? null : v[rng.nextInt(v.length)];
        // whether use quantity?
        final w = i?.isNotEmpty == true && rng.nextBool() ? i!.itemList : null;
        final q = w == null ? null : w[rng.nextInt(w.length)];
        ordered.add(OrderProductObject(
          productId: product.id,
          productName: product.name,
          catalogName: product.catalog.name,
          count: 1,
          cost: product.cost,
          singlePrice: product.price,
          originalPrice: product.price,
          isDiscount: rng.nextBool(),
          ingredients: i == null
              ? []
              : [
                  OrderIngredientObject(
                    id: i.ingredient.id,
                    name: i.name,
                    productIngredientId: i.id,
                    productQuantityId: q?.id,
                    additionalPrice: q?.additionalPrice,
                    additionalCost: q?.additionalCost,
                    amount: i.amount,
                    quantityId: q?.quantity.id,
                    quantityName: q?.quantity.name,
                  )
                ],
        ));
      }
    }

    final attrs = [
      for (var attr in OrderAttributes.instance.items) generateAttr(attr),
    ];

    final price = ordered.fold<num>(0, (p, e) => p + e.totalPrice);
    final attrPrice = attrs
        .where((attr) => attr.mode == OrderAttributeMode.changePrice)
        .fold<num>(0, (p, e) => p + (e.modeValue ?? 0));
    result.add(OrderObject(
      createdAt: startFrom.add(Duration(minutes: createdList[orderCount])),
      paid: price + attrPrice,
      totalPrice: price + attrPrice,
      productsPrice: price,
      totalCount: ordered.fold<int>(0, (p, e) => p + e.count),
      productNames: ordered.map((e) => e.productName).toList(),
      ingredientNames: ordered
          .expand((e) => e.ingredients.map((i) => i.name))
          .toSet()
          .toList(),
      attributes: attrs,
      products: ordered,
    ));
  }

  return result;
}

List<int> _selectExistedProduct<T>(List<OrderProductObject> data, String id) {
  final result = <int>[];
  for (var i = 0, n = data.length; i < n; i++) {
    if (data[i].productId == id) {
      result.add(i);
    }
  }

  return result;
}

class RandomGenerateOrderButton extends StatelessWidget {
  const RandomGenerateOrderButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const _SettingPage())),
      label: const Text('產生隨機餐點'),
      icon: const Icon(Icons.developer_mode_sharp),
    );
  }
}

class _SettingPage extends StatefulWidget {
  const _SettingPage({Key? key}) : super(key: key);

  @override
  State<_SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<_SettingPage> {
  final DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  final _countController = TextEditingController(text: '1');

  late DateTime startFrom;
  late DateTime endTo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PopButton(),
        actions: [
          TextButton(
            onPressed: () => submit(context.read<Seller>()),
            child: const Text('OK'),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          TextFormField(
            key: const Key('rgo.count'),
            controller: _countController,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '訂單數量',
              hintText: '平均分配於時間區間',
            ),
            maxLength: 5,
            validator: Validator.positiveInt('訂單數量', maximum: 9999, minimum: 1),
          ),
          const SizedBox(height: 8.0),
          InkWell(
            key: const Key('rgo.date_range'),
            onTap: selectDates,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(dateFormat.format(startFrom)),
                  const Icon(Icons.horizontal_rule_outlined),
                  Text(dateFormat.format(endTo)),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> selectDates() async {
    const oneDay = Duration(days: 1);
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateUtils.dateOnly(DateTime.now()),
      initialDateRange: DateTimeRange(
        start: startFrom,
        end: endTo.subtract(oneDay),
      ),
    );

    if (selected != null) {
      setState(() {
        startFrom = selected.start;
        endTo = selected.end.add(oneDay);
      });
    }
  }

  void submit(Seller seller) async {
    final count = int.tryParse(_countController.text);
    final result = generateOrder(
      orderCount: count ?? 0,
      startFrom: startFrom,
      endTo: endTo,
    );

    await Future.forEach<OrderObject>(result, (e) => seller.push(e));
    if (context.mounted) {
      showSnackBar(context, '成功產生 ${result.length} 個訂單');

      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    final r = Util.getDateRange();
    startFrom = r.start;
    endTo = r.end;
    super.initState();
  }
}
