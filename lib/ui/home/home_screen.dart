import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:simple_tip/simple_tip.dart';

import 'widgets/order_info.dart';

class HomeScreen extends StatelessWidget {
  static const icons = {
    'store': {
      'menu': _LabledIconItem(
        icon: Icons.collections_sharp,
        label: 'menu',
        route: Routes.menu,
        tipVersion: 1,
      ),
      'stock': _LabledIconItem(
        icon: Icons.store_sharp,
        label: 'stock',
        route: Routes.stock,
        tipVersion: 1,
      ),
      'quantities': _LabledIconItem(
        icon: Icons.exposure_sharp,
        label: 'quantities',
        route: Routes.stockQuantity,
      ),
      'cashier': _LabledIconItem(
        icon: Icons.attach_money_sharp,
        label: 'cashier',
        route: Routes.cashier,
        tipVersion: 1,
      ),
      'customer': _LabledIconItem(
        icon: Icons.assignment_ind_sharp,
        label: 'customer',
        route: Routes.customer,
        tipVersion: 1,
      ),
    },
    'other': {
      'analysis': _LabledIconItem(
        icon: Icons.equalizer_sharp,
        label: 'analysis',
        route: Routes.analysis,
        tipVersion: 1,
      ),
      'setting': _LabledIconItem(
        icon: Icons.settings_sharp,
        label: 'setting',
        route: Routes.setting,
      ),
    },
  };

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    var count = 0;

    final icons = <Widget>[
      for (var entry in HomeScreen.icons.entries)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.homeIconTypes(entry.key), style: theme.textTheme.headline5),
            Wrap(spacing: 8.0, children: [
              for (final item in entry.value.values)
                _LabledIcon(item, index: count++)
            ]),
            const Divider(),
          ],
        )
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(kSpacing3),
        child: Column(
          children: [
            const OrderInfo(),
            const SizedBox(height: kSpacing2),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: icons,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabledIcon extends StatelessWidget {
  final _LabledIconItem item;

  final int index;

  const _LabledIcon(this.item, {required this.index});

  @override
  Widget build(BuildContext context) {
    final base = TextButton(
      key: Key('home.${item.label}'),
      onPressed: () => Navigator.of(context).pushNamed(item.route),
      style: TextButton.styleFrom(shape: const CircleBorder()),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(item.icon, size: 48.0),
          Text(S.homeIcons(item.label)),
        ],
      ),
    );

    if (item.tipVersion == 0) {
      return base;
    }

    return OrderedTip(
      groupId: 'home',
      title: S.homeIcons(item.label),
      message: S.homeIconTutorial(item.label),
      id: item.label,
      version: item.tipVersion,
      order: index,
      child: base,
    );
  }
}

class _LabledIconItem {
  final IconData? icon;
  final String label;
  final String route;
  final int tipVersion;

  const _LabledIconItem({
    this.icon,
    required this.label,
    required this.route,
    this.tipVersion = 0,
  });
}
