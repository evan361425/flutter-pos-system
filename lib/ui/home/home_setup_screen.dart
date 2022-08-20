import 'package:flutter/material.dart';
import 'package:possystem/components/linkify.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/route_tile.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/debug/random_gen_order.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

class HomeSetupScreen extends StatelessWidget {
  const HomeSetupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const isProd = String.fromEnvironment('appFlavor') == 'prod';

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeaderInfoList(),
            if (!isProd) const Center(child: RandomGenerateOrderButton()),
            RouteTile(
              key: const Key('home_setup.menu'),
              icon: Icons.collections_outlined,
              route: Routes.menu,
              title: S.menuTitle,
            ),
            RouteTile(
              key: const Key('home_setup.exporter'),
              icon: Icons.upload_file_outlined,
              route: Routes.exporter,
              title: S.exporterTitle,
            ),
            RouteTile(
              key: const Key('home_setup.order_attrs'),
              icon: Icons.assignment_ind_outlined,
              route: Routes.orderAttr,
              title: S.orderAttributeTitle,
            ),
            RouteTile(
              key: const Key('home_setup.quantities'),
              icon: Icons.exposure_outlined,
              route: Routes.quantities,
              title: S.quantityTitle,
            ),
            RouteTile(
              key: const Key('home_setup.feature_request'),
              icon: Icons.lightbulb_outlined,
              route: Routes.featureRequest,
              title: S.featureRequestTitle,
            ),
            RouteTile(
              key: const Key('home_setup.setting'),
              icon: Icons.settings_outlined,
              route: Routes.setting,
              title: S.settingTitle,
            ),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
              Linkify([LinkifyData('Privacy Policy', _privacyPolicy)]),
              Text(MetaBlock.string),
              Linkify([LinkifyData('License', _license)]),
            ])
          ],
        ),
      ),
    );
  }
}

class _HeaderInfo extends StatelessWidget {
  final int title;

  final String subtitle;

  final String route;

  const _HeaderInfo({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.route,
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
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(route),
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
      ),
    );
  }
}

class _HeaderInfoList extends StatelessWidget {
  const _HeaderInfoList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<Menu>();
    final attrs = context.watch<OrderAttributes>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0, 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          _HeaderInfo(
            key: const Key('home_setup.header.menu1'),
            title: menu.items.fold<int>(0, (v, e) => e.length + v),
            subtitle: '產品',
            route: Routes.menu,
          ),
          _HeaderInfo(
            key: const Key('home_setup.header.menu2'),
            title: menu.length,
            subtitle: '種類',
            route: Routes.menu,
          ),
          _HeaderInfo(
            key: const Key('home_setup.header.order_attrs'),
            title: attrs.length,
            subtitle: '顧客設定',
            route: Routes.orderAttr,
          ),
        ]),
      ),
    );
  }
}

const _privacyPolicy =
    'https://evan361425.github.io/flutter-pos-system/PRIVACY_POLICY/';
const _license = 'https://evan361425.github.io/flutter-pos-system/LICENSE/';
