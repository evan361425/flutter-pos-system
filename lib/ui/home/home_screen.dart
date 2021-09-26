import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:simple_tip/simple_tip.dart';

import 'widgets/order_info.dart';
import 'widgets/upgrade_alert.dart';

class HomeScreen extends StatelessWidget {
  static const icons = {
    'home.types.store': {
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
    'home.types.other': {
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
            Text(tt(entry.key), style: theme.textTheme.headline5),
            Wrap(spacing: 8.0, children: [
              for (final item in entry.value.values)
                _LabledIcon(item, index: count++)
            ]),
            Divider(),
          ],
        )
    ];

    return Scaffold(
      body: SafeArea(
        child: UpgradeAlert(
          child: Padding(
            padding: const EdgeInsets.all(kSpacing3),
            child: Column(
              children: [
                OrderInfo(),
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
      onPressed: () => Navigator.of(context).pushNamed(item.route),
      style: TextButton.styleFrom(shape: CircleBorder()),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(item.icon, size: 48.0),
          Text(tt('home.${item.label}')),
        ],
      ),
    );

    if (item.tipVersion == 0) {
      return base;
    }

    return OrderedTip(
      groupId: 'home',
      title: tt('home.${item.label}'),
      message: tt('home.tutorial.${item.label}'),
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
