import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:provider/provider.dart';

/// Generate order records each record have total 1~10 products. For example,
/// 1 product might have 10 count or 10 different products or 2 same product but
/// each have different ingredients.
List<OrderObject> generateOrder({
  required int orderCount,
  required DateTime startFrom,
  required DateTime endTo,
}) {
  final rng = Random();
  final products = Menu.instance.products.toList();
  final result = <OrderObject>[];

  final interval = endTo.difference(startFrom).inMinutes;
  if (interval == 0 || products.isEmpty) return const [];

  final createdList = [
    for (var i = 0; i < orderCount; i++) rng.nextInt(interval)
  ]..sort();

  while (orderCount-- > 0) {
    final ordered = <OrderProductObject>[];
    // 1~10
    var round = rng.nextInt(10) + 1;
    while (round-- != 0) {
      // random choose product
      final product = products[rng.nextInt(products.length)];

      // if already ordered that product, possibly increment the count
      final possible = _selectExistedProduct(ordered, product.id);
      if (possible.isNotEmpty && rng.nextBool()) {
        final idx = possible[rng.nextInt(possible.length)];
        final map = ordered[idx].toMap();
        map['count'] = (map['count'] as int) + 1;
        ordered[idx] = OrderProductObject.fromMap(
          map,
          ordered[idx].ingredients.map((e) => e.toMap()),
        );
      } else {
        final isDiscount = rng.nextInt(5) == 0;
        ordered.add(OrderProductObject(
          productId: product.id,
          productName: product.name,
          catalogName: product.catalog.name,
          count: 1,
          singleCost: product.cost,
          singlePrice: isDiscount
              ? (product.price * rng.nextDouble()).toCurrencyNum()
              : product.price,
          originalPrice: product.price,
          isDiscount: isDiscount,
          ingredients: product.items.map((e) {
            final qIdx = e.isEmpty ? 0 : rng.nextInt(e.length * 2);
            final q = qIdx < e.length ? e.items.toList()[qIdx] : null;
            return OrderIngredientObject(
              ingredientName: e.name,
              quantityName: q?.name,
              additionalPrice: q?.additionalPrice ?? 0,
              additionalCost: q?.additionalCost ?? 0,
              amount: q?.amount ?? e.amount,
              ingredientId: e.ingredient.id,
              productIngredientId: e.id,
            );
          }).toList(),
        ));
      }
    }

    final attrs =
        OrderAttributes.instance.items.where((e) => e.isNotEmpty).map((e) {
      final idx = rng.nextInt(e.length);
      final opt = e.items.toList()[idx];

      return OrderSelectedAttributeObject.fromModel(opt);
    }).toList();

    final originalPrice = ordered.fold<num>(0, (p, e) => p + e.totalPrice);
    // only change price when mode is changePrice.
    final price = attrs
        .where((attr) => attr.mode == OrderAttributeMode.changePrice)
        .fold<num>(originalPrice, (p, e) => p + (e.modeValue ?? 0));

    result.add(OrderObject(
      createdAt: startFrom.add(Duration(minutes: createdList[orderCount])),
      paid: price + rng.nextInt(100),
      cost: ordered.fold<num>(0, (p, e) => p + e.totalCost),
      price: price,
      productsCount: ordered.fold<int>(0, (p, e) => p + e.count),
      productsPrice: originalPrice,
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
