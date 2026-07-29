import 'dart:developer';

import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/translator.dart';

Future<void> setupExampleMenu() async {
  if (Menu.instance.isNotEmpty) return;

  log('setting Elbe-Jade seafood catalog', name: 'example menu');
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  for (final e in [
    _catalog(
      id: 'live',
      index: 1,
      name: '🦀 Lebend',
      now: now,
      products: [
        ('blue-crab-l', 'Griechische Blaukrabbe L · €/kg', 20, 13),
        ('blue-crab-xl', 'Griechische Blaukrabbe XL · €/kg', 30, 20),
        ('blue-crab-xxl', 'Griechische Blaukrabbe XXL · €/kg', 40, 28),
        ('canada-lobster', 'Kanadischer Hummer 400–1000 g · €/kg', 58, 42),
        ('canada-lobster-jumbo', 'Kanadischer Hummer ≥1000 g · €/kg', 68, 49),
        ('creuses-oysters', 'Creuses Austern · 12 Stück', 18, 10.68),
        ('belon-oysters', 'Belon Austern · 6 Stück', 25, 15),
        ('sylt-mussels', 'Sylter Miesmuscheln · €/kg', 10, 6),
      ],
    ),
    _catalog(
      id: 'fresh',
      index: 2,
      name: '🐟 Frisch',
      now: now,
      products: [
        ('salmon-sashimi', 'Lachsfilet Sashimi · €/kg', 38, 25),
        ('grouper', 'Zackenbarsch 500–1000 g · €/kg', 38, 27),
        ('sea-bream', 'Dorade Royal · €/kg', 19, 12),
        ('sea-bass', 'Loup de Mer · Stück', 7, 4),
        ('zander', 'Zander 1–2 kg · €/kg', 28, 20),
        ('salmon-caviar', 'Lachskaviar · Glas', 25, 17),
      ],
    ),
    _catalog(
      id: 'frozen',
      index: 3,
      name: '❄️ Tiefgekühlt',
      now: now,
      products: [
        ('sweet-shrimp', 'Nordische Eismeergarnelen · Beutel', 13, 8),
        ('argentina-shrimp', 'Argentinische Rotgarnelen L1 · 2 kg', 38, 27),
        ('black-tiger-812', 'Black-Tiger Garnelen 8/12 · 800 g', 28, 19),
        ('black-tiger-2630', 'Black-Tiger Garnelen 26/30 · 800 g', 19, 13),
        ('unagi', 'Kabayaki Aal · Packung', 16, 7.69),
        ('edamame', 'Edamame · 1 kg', 5, 3),
      ],
    ),
  ]) {
    await Menu.instance.addItem(e);
  }
}

Catalog _catalog({
  required String id,
  required int index,
  required String name,
  required int now,
  required List<(String, String, num, num)> products,
}) {
  return Catalog.fromObject(
    CatalogObject.build({
      'id': id,
      'index': index,
      'name': name,
      'createdAt': now,
      'products': {
        for (final (position, product) in products.indexed)
          product.$1: {
            'price': product.$3,
            'cost': product.$4,
            'index': position + 1,
            'name': product.$2,
            'createdAt': now,
            'ingredients': <String, Object?>{},
          },
      },
    }),
  );
}

Future<void> setupExampleOrderAttrs() async {
  if (OrderAttributes.instance.isNotEmpty) return;

  log('setting order attributes', name: 'example order attrs');
  for (final e in [
    OrderAttribute(
      id: 'age',
      name: S.orderAttributeExampleAge,
      index: 1,
      mode: .statOnly,
      options: {
        'child': OrderAttributeOption(
          id: 'child',
          name: '${S.orderAttributeExampleAgeChild} (0-12)',
          index: 1,
        ),
        'adult': OrderAttributeOption(
          id: 'adult',
          name: '${S.orderAttributeExampleAgeAdult} (13-60)',
          index: 2,
          isDefault: true,
        ),
        'senior': OrderAttributeOption(
          id: 'senior',
          name: '${S.orderAttributeExampleAgeSenior} (60+)',
          index: 3,
        ),
      },
    )..prepareItem(),
    OrderAttribute(
      id: 'place',
      name: S.orderAttributeExamplePlace,
      index: 2,
      mode: .changeDiscount,
      options: {
        'takeout': OrderAttributeOption(
          id: 'takeout',
          name: S.orderAttributeExamplePlaceTakeout,
          index: 1,
          isDefault: true,
        ),
        'dine-in': OrderAttributeOption(
          id: 'dine-in',
          name: S.orderAttributeExamplePlaceDineIn,
          index: 2,
          modeValue: 1.1,
        ),
      },
    )..prepareItem(),
    OrderAttribute(
      id: 'eco-friendly',
      name: S.orderAttributeExampleEcoFriendly,
      index: 3,
      mode: .changePrice,
      options: {
        'reuseable-bag': OrderAttributeOption(
          id: 'reuseable-bag',
          name: S.orderAttributeExampleEcoFriendlyReusableBag,
          index: 1,
          modeValue: -5,
        ),
        'reuseable-bottle': OrderAttributeOption(
          id: 'reuseable-bottle',
          name: S.orderAttributeExampleEcoFriendlyReusableBottle,
          index: 1,
          modeValue: -30,
        ),
      },
    )..prepareItem(),
  ]) {
    await OrderAttributes.instance.addItem(e);
  }
}
