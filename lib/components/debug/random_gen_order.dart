import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/style/appbar_text_button.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/seller.dart';

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
  final createdList = [
    for (var i = 0; i < orderCount; i++) rng.nextInt(interval)
  ]..sort();

  while (orderCount-- != 0) {
    final ordered = <Map<String, Object>>[];
    // 1~10
    var round = rng.nextInt(10) + 1;
    while (round-- != 0) {
      // random choose product
      final product = products[rng.nextInt(productCount)];

      // if already ordered that product, possibly increment the count
      final possible = _allIndexIn(ordered, 'productId', product.id);
      if (possible.isNotEmpty && rng.nextBool()) {
        final o = ordered[possible[rng.nextInt(possible.length)]];
        o['count'] = (o['count'] as int) + 1;
      } else {
        // whether use ingredient?
        final v = product.itemList;
        final i = v.isEmpty || rng.nextBool() ? null : v[rng.nextInt(v.length)];
        // whether use quantity?
        final w = i?.isNotEmpty == true && rng.nextBool() ? i!.itemList : null;
        final q = w == null ? null : w[rng.nextInt(w.length)];
        ordered.add({
          'singlePrice': product.price,
          'originalPrice': product.price,
          'count': 1,
          'productId': product.id,
          'productName': product.name,
          'isDiscount': rng.nextBool(),
          'ingredients': i == null
              ? []
              : [
                  {
                    'id': i.ingredient.id,
                    'name': i.name,
                    'productIngredientId': i.id,
                    'productQuantityId': q?.id,
                    'additionalPrice': q?.additionalPrice,
                    'additionalCost': q?.additionalCost,
                    'amount': i.amount,
                    'quantityId': q?.quantity.id,
                    'quantityName': q?.quantity.name,
                  }
                ],
        });
      }
    }

    final price = ordered.fold<int>(
        0, (p, e) => p + (e['singlePrice'] as int) * (e['count'] as int));
    result.add(OrderObject(
      createdAt: startFrom.add(Duration(minutes: createdList[orderCount])),
      paid: price,
      totalPrice: price,
      totalCount: ordered.fold<int>(0, (p, e) => p + (e['count'] as int)),
      productsPrice: price,
      productNames: ordered.map((e) => e['productName'] as String).toList(),
      ingredientNames: ordered
          .expand((e) =>
              (e['ingredients'] as List).map((i) => (i['name'] as String)))
          .toSet()
          .toList(),
      products: ordered.map((product) => OrderProductObject.input(product)),
    ));
  }

  return result;
}

List<int> _allIndexIn<T>(List<Map<String, Object>> data, String key, T needle) {
  final result = <int>[];
  for (var i = 0, n = data.length; i < n; i++) {
    if (data[i][key] == needle) {
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
          AppbarTextButton(
            onPressed: submit,
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
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: startFrom, end: endTo),
    );

    if (selected != null) {
      setState(() {
        startFrom = selected.start;
        endTo = selected.end;
      });
    }
  }

  void submit() async {
    final count = int.parse(_countController.text);
    final result = generateOrder(
      orderCount: count,
      startFrom: startFrom,
      endTo: endTo,
    );

    await Future.forEach<OrderObject>(result, (e) => Seller.instance.push(e));
    showSuccessSnackbar(context, '成功產生 ${result.length} 個訂單');

    Navigator.of(context).pop();
  }

  @override
  void initState() {
    endTo = DateTime.now();
    startFrom = endTo.subtract(const Duration(days: 1));
    super.initState();
  }
}
