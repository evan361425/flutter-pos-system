import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/style/route_tile.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/debug/random_gen_order.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';
import 'package:provider/provider.dart';

class HomeSetupScreen extends StatelessWidget {
  const HomeSetupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _HeaderInfoList(),
            if (kDebugMode || String.fromEnvironment('app.flavor') == 'dev')
              Center(child: RandomGenerateOrderButton()),
            RouteTile(
              key: Key('home_setup.menu'),
              icon: Icons.collections_outlined,
              route: Routes.menu,
              title: '菜單',
            ),
            RouteTile(
              key: Key('home_setup.exporter'),
              icon: Icons.upload_file_outlined,
              route: Routes.exporter,
              title: '匯出資料',
            ),
            RouteTile(
              key: Key('home_setup.customer'),
              icon: Icons.assignment_ind_outlined,
              route: Routes.customer,
              title: '顧客設定',
            ),
            RouteTile(
              key: Key('home_setup.quantities'),
              icon: Icons.exposure_outlined,
              route: Routes.quantities,
              title: '份量',
            ),
            RouteTile(
              key: Key('home_setup.feature_request'),
              icon: Icons.lightbulb_outlined,
              route: Routes.featureRequest,
              title: '建議',
            ),
            RouteTile(
              key: Key('home_setup.setting'),
              icon: Icons.settings_outlined,
              route: Routes.setting,
              title: '其他設定',
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderInfo extends StatelessWidget {
  final int title;

  final String subtitle;

  const _HeaderInfo({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 128,
      width: 128,
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: theme.gradientColors,
          tileMode: TileMode.clamp,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title.toString(),
            style: theme.textTheme.headline4,
          ),
          Text(subtitle),
        ],
      ),
    );
  }
}

class _HeaderInfoList extends StatelessWidget {
  const _HeaderInfoList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<Menu>();
    final customerSetting = context.watch<CustomerSettings>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0, 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          _HeaderInfo(
            title: menu.items.fold<int>(0, (v, e) => e.length + v),
            subtitle: '產品',
          ),
          _HeaderInfo(
            title: menu.length,
            subtitle: '種類',
          ),
          _HeaderInfo(
            title: customerSetting.length,
            subtitle: '顧客設定',
          ),
        ]),
      ),
    );
  }
}
