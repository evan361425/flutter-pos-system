import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/home/widgets/order_info.dart';
import 'package:possystem/ui/home/widgets/upgrade_alert.dart';
import 'package:simple_tip/simple_tip.dart';

class HomeScreen extends StatelessWidget {
  static const icons = {
    'home.types.store': {
      'menu': _LabeledIcon(
        icon: Icons.collections_sharp,
        label: 'menu',
        route: Routes.menu,
        tipVersion: 1,
      ),
      'stock': _LabeledIcon(
        icon: Icons.store_sharp,
        label: 'stock',
        route: Routes.stock,
        tipVersion: 1,
      ),
      'quantities': _LabeledIcon(
        icon: Icons.exposure_sharp,
        label: 'quantities',
        route: Routes.stockQuantity,
      ),
      'cashier': _LabeledIcon(
        icon: Icons.attach_money_sharp,
        label: 'cashier',
        route: Routes.cashier,
        tipVersion: 1,
      ),
    },
    'home.types.other': {
      'analysis': _LabeledIcon(
        icon: Icons.equalizer_sharp,
        label: 'analysis',
        route: Routes.analysis,
        tipVersion: 1,
      ),
      'setting': _LabeledIcon(
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
              for (var item in entry.value.values)
                item.tipVersion == 0
                    ? item.toButton(context)
                    : OrderedTip(
                        groupId: 'home',
                        title: tt('home.${item.label}'),
                        message: tt('home.tutorial.${item.label}'),
                        id: item.label,
                        version: item.tipVersion,
                        order: count++,
                        child: item.toButton(context),
                      )
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

class _LabeledIcon {
  final IconData? icon;
  final String label;
  final String? route;
  final int tipVersion;

  const _LabeledIcon({
    this.icon,
    required this.label,
    this.route,
    this.tipVersion = 0,
  });

  Widget toButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pushNamed(route!),
      style: TextButton.styleFrom(shape: CircleBorder()),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 48.0),
          Text(tt('home.$label')),
        ],
      ),
    );
  }
}
