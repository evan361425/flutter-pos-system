import 'package:flutter/material.dart';
import 'package:possystem/components/style/custom_styles.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/my_app.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/home/home_tutorial.dart';
import 'package:possystem/ui/home/widgets/order_info.dart';
import 'package:possystem/ui/home/widgets/upgrade_alert.dart';

class HomeScreen extends StatefulWidget {
  static final icons = {
    'home.types.store': [
      _LabeledIcon(
        key: GlobalKey(),
        icon: Icons.collections_sharp,
        label: 'menu',
        route: Routes.menu,
      ),
      _LabeledIcon(
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
      _LabeledIcon(
        icon: Icons.exposure_sharp,
        label: 'quantities',
        route: Routes.stockQuantity,
      ),
      // _LabeledIcon(
      //   icon: Icons.attach_money_sharp,
      //   label: '收銀機',
      //   route: Routes.cashier,
      // ),
    ],
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
    'home.types.other': [
      _LabeledIcon(
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
      _LabeledIcon(
        icon: Icons.settings_sharp,
        label: 'setting',
        route: Routes.setting,
      ),
    ],
  };

  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  static final orderInfo = GlobalKey<OrderInfoState>();

  static HomeTutorial? tutorial;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MyApp.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    MyApp.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    showTutorialIfNeed(context);
    orderInfo.currentState?.reset();
  }

  @override
  void didPopNext() {
    showTutorialIfNeed(context);
    orderInfo.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: UpgradeAlert(
          child: Padding(
            padding: const EdgeInsets.all(kSpacing3),
            child: Column(
              children: [
                OrderInfo(key: orderInfo),
                const SizedBox(height: kSpacing2),
                Expanded(child: _iconsWithTitle(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconsWithTitle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: HomeScreen.icons.entries
            .map<Widget>((entry) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key, style: textTheme.headline5),
                    Wrap(spacing: 8.0, children: entry.value),
                    Divider(),
                  ],
                ))
            .toList(),
      ),
    );
  }

  void showTutorialIfNeed(BuildContext context) {
    tutorial?.finish();
    if (Cache.instance.needTutorial('home.menu')) {
      tutorial = HomeTutorial.menu(context)..show();
    } else if (Cache.instance.needTutorial('home.icons')) {
      tutorial = HomeTutorial.icons(context)..show();
    }
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
          Icon(icon, size: 48.0, color: theme.primaryColorDark),
          Text(tt(label), style: TextStyle(color: theme.textTheme.muted.color)),
        ],
      ),
    );
  }
}
