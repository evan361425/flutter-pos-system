import 'package:flutter/material.dart';
import 'package:possystem/components/style/custom_styles.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/home/home_tutorial.dart';
import 'package:possystem/ui/home/widgets/order_info.dart';
import 'package:possystem/ui/home/widgets/upgrade_alert.dart';

class HomeScreen extends StatefulWidget {
  static final icons = {
    'home.types.store': {
      'menu': _LabeledIcon(
        key: GlobalKey(),
        icon: Icons.collections_sharp,
        label: 'menu',
        route: Routes.menu,
      ),
      'stock': _LabeledIcon(
        key: GlobalKey(),
        icon: Icons.store_sharp,
        label: 'stock',
        route: Routes.stock,
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
        key: GlobalKey(),
        icon: Icons.attach_money_sharp,
        label: 'cashier',
        route: Routes.cashier,
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
        key: GlobalKey(),
        icon: Icons.equalizer_sharp,
        label: 'analysis',
        route: Routes.analysis,
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

class _HomeScreenState extends State<HomeScreen>
    with RouteAware, TutorialAware<HomeScreen> {
  static final orderInfo = GlobalKey<OrderInfoState>();

  @override
  final String tutorialName = 'home';

  @override
  final int tutorialVersion = 1;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final icons = HomeScreen.icons.entries
        .map<Widget>((entry) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tt(entry.key), style: textTheme.headline5),
                Wrap(spacing: 8.0, children: entry.value.values.toList()),
                Divider(),
              ],
            ))
        .toList();

    return Scaffold(
      body: SafeArea(
        child: UpgradeAlert(
          child: Padding(
            padding: const EdgeInsets.all(kSpacing3),
            child: Column(
              children: [
                OrderInfo(key: orderInfo),
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

  @override
  void didPopNext() {
    super.didPopNext();
    orderInfo.currentState?.reset();
  }

  @override
  void didPush() {
    super.didPush();
    orderInfo.currentState?.reset();
  }

  @override
  bool showTutorialIfNeed() {
    for (final name in TutorialName.values) {
      final steps = Cache.instance.neededTutorial(
        'home.$name',
        HomeTutorial.STEPS[name]!,
      );

      if (steps.isNotEmpty) {
        showTutorial(() => HomeTutorial.steps(context, name, steps));
        return false;
      }
    }
    return true;
  }
}

class _LabeledIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _LabeledIcon({
    GlobalKey? key,
    required this.icon,
    required this.label,
    required this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: () => Navigator.of(context).pushNamed(route),
      style: TextButton.styleFrom(shape: CircleBorder()),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 48.0),
          Text(
            tt('home.$label'),
            style: TextStyle(color: theme.textTheme.muted.color),
          ),
        ],
      ),
    );
  }
}
