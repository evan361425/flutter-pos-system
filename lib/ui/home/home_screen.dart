import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/components/custom_styles.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/storage.dart';
import 'package:possystem/ui/home/widgets/order_info.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static final orderInfo = GlobalKey<OrderInfoState>();

  static const icons = {
    '店家設定': [
      _LabeledIcon(
        icon: Icons.collections_sharp,
        label: '菜單',
        route: Routes.menu,
      ),
      _LabeledIcon(
        icon: Icons.store_sharp,
        label: '庫存',
        route: Routes.stock,
      ),
      _LabeledIcon(
        icon: Icons.assignment_ind_sharp,
        label: '客戶資訊',
        route: Routes.customer,
      ),
      _LabeledIcon(
        icon: Icons.exposure_sharp,
        label: '份量',
        route: Routes.stockQuantity,
      ),
      _LabeledIcon(
        icon: Icons.attach_money_sharp,
        label: '收銀機',
        route: Routes.cashier,
      ),
    ],
    '外部連結': [
      _LabeledIcon(
        icon: Icons.camera_roll_sharp,
        label: '發票機',
        route: Routes.invoicer,
      ),
      _LabeledIcon(
        icon: Icons.print_sharp,
        label: '出單機',
        route: Routes.printer,
      ),
    ],
    '其他': [
      _LabeledIcon(
        icon: Icons.equalizer_sharp,
        label: '統計',
        route: Routes.analysis,
      ),
      _LabeledIcon(
        icon: Icons.import_export_sharp,
        label: '匯出匯入',
        route: Routes.transfer,
      ),
      _LabeledIcon(
        icon: Icons.settings_sharp,
        label: '設定',
        route: Routes.setting,
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
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
    );
  }

  Widget _iconsWithTitle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: icons.entries
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
}

class _LabeledIcon extends StatelessWidget {
  const _LabeledIcon({
    Key? key,
    required this.icon,
    required this.label,
    required this.route,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final String route;

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
          Text(label, style: TextStyle(color: theme.textTheme.muted.color)),
        ],
      ),
    );
  }
}
