import 'package:flutter/material.dart';
import 'package:possystem/components/tip.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/home/widgets/order_info.dart';
import 'package:possystem/ui/home/widgets/upgrade_alert.dart';

class HomeScreen extends StatefulWidget {
  static const order = _LabeledIcon(label: 'order', tipVersion: 1);
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
      // _LabeledIcon(
      //   icon: Icons.assignment_ind_sharp,
      //   label: '客戶資訊',
      //   route: Routes.customer,
      // ),
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
    // '外部連結': [
    //   _LabeledIcon(
    //     icon: Icons.camera_roll_sharp,
    //     label: '發票機',
    //     route: Routes.invoicer,
    //   ),
    //   _LabeledIcon(
    //     icon: Icons.print_sharp,
    //     label: '出單機',
    //     route: Routes.printer,
    //   ),
    // ],
    'home.types.other': {
      'analysis': _LabeledIcon(
        icon: Icons.equalizer_sharp,
        label: 'analysis',
        route: Routes.analysis,
        tipVersion: 1,
      ),
      // _LabeledIcon(
      //   icon: Icons.import_export_sharp,
      //   label: '匯出匯入',
      //   route: Routes.transfer,
      // ),
      'setting': _LabeledIcon(
        icon: Icons.settings_sharp,
        label: 'setting',
        route: Routes.setting,
      ),
    },
  };

  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool oneTipIsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabledLabel = _getEnabledLabel();

    final icons = <Widget>[
      for (var entry in HomeScreen.icons.entries)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tt(entry.key), style: theme.textTheme.headline5),
            Wrap(spacing: 8.0, children: [
              for (var item in entry.value.values)
                Tip(
                  title: tt('home.${item.label}'),
                  message: tt('home.tutorial.${item.label}'),
                  disabled: item.label != enabledLabel,
                  onClosed: () {
                    item.tipRead();
                    // there is no tip enabled, now we can research
                    setState(() => oneTipIsEnabled = false);
                  },
                  child: item.toButton(context),
                )
            ]),
            Divider(),
          ],
        )
    ];

    final orderInfo = enabledLabel == null && !HomeScreen.order.tipDisabled
        ? Tip(
            title: tt('home.order'),
            message: tt('home.tutorial.order'),
            onClosed: () {
              HomeScreen.order.tipRead();
              setState(() => oneTipIsEnabled = false);
            },
            child: OrderInfo(),
          )
        : OrderInfo();

    return Scaffold(
      body: SafeArea(
        child: UpgradeAlert(
          child: Padding(
            padding: const EdgeInsets.all(kSpacing3),
            child: Column(
              children: [
                orderInfo,
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

  String? _getEnabledLabel() {
    for (final group in HomeScreen.icons.values) {
      for (final item in group.values) {
        if (!item.tipDisabled) {
          oneTipIsEnabled = true;
          return item.label;
        }
      }
    }
    return null;
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

  bool get tipDisabled => !Cache.instance.neededTip('home.$label', tipVersion);

  Future<bool> tipRead() {
    return Cache.instance.tipRead('home.$label', tipVersion);
  }

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
