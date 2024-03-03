import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/linkify.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/debug/random_gen_order.dart';
import 'package:possystem/debug/rerun_migration.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';
import 'package:spotlight_ant/spotlight_ant.dart';

class SettingView extends StatelessWidget {
  final TutorialInTab? tab;

  const SettingView({
    super.key,
    this.tab,
  });

  @override
  Widget build(BuildContext context) {
    const isProd = String.fromEnvironment('appFlavor') == 'prod';

    return TutorialWrapper(
      tab: tab,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeaderInfoList(),
            if (!isProd)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  const RandomGenerateOrderButton(),
                  ElevatedButton.icon(
                    onPressed: Cache.instance.reset,
                    label: const Text('清除快取'),
                    icon: const Icon(Icons.clear_all_sharp),
                  ),
                  const RerunMigration(),
                ]),
              ),
            Tutorial(
              id: 'home.menu',
              index: 2,
              message: '現在就趕緊來設定菜單吧！',
              spotlightBuilder: const SpotlightRectBuilder(),
              disable: Menu.instance.isNotEmpty,
              child: _buildRouteTile(
                context,
                id: 'menu',
                icon: Icons.collections_sharp,
                route: Routes.menu,
                title: S.menuTitle,
                subtitle: '產品種類、產品',
              ),
            ),
            Tutorial(
              id: 'home.exporter',
              index: 1,
              title: '資料轉移',
              message: '這裡是用來匯入匯出菜單、庫存、訂單記錄等資訊的地方。',
              spotlightBuilder: const SpotlightRectBuilder(),
              child: _buildRouteTile(
                context,
                id: 'exporter',
                icon: Icons.upload_file_sharp,
                route: Routes.transit,
                title: S.transitTitle,
                subtitle: '匯入、匯出資料',
              ),
            ),
            Tutorial(
              id: 'home.order_attr',
              index: 0,
              title: '顧客設定',
              message: '這裡可以設定顧客資訊，例如：\n'
                  '內用，加價一成；\n'
                  '外帶，維持原價。',
              spotlightBuilder: const SpotlightRectBuilder(),
              child: _buildRouteTile(
                context,
                id: 'order_attrs',
                icon: Icons.assignment_ind_sharp,
                route: Routes.orderAttr,
                title: S.orderAttributeTitle,
                subtitle: '內用、外帶等等',
              ),
            ),
            _buildRouteTile(
              context,
              id: 'quantity',
              icon: Icons.exposure_sharp,
              route: Routes.quantity,
              title: S.quantityTitle,
              subtitle: '半糖、微糖等等',
            ),
            _buildRouteTile(
              context,
              id: 'feature_request',
              icon: Icons.lightbulb_sharp,
              route: Routes.featureRequest,
              title: S.featureRequestTitle,
              subtitle: '使用 Google 表單提供回饋',
            ),
            _buildRouteTile(
              context,
              id: 'setting',
              icon: Icons.settings_sharp,
              route: Routes.features,
              title: S.settingTitle,
              subtitle: '外觀、語言、提示',
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              TextButton(
                onPressed: _bottomLinks[0].launch,
                child: Text(_bottomLinks[0].text),
              ),
              const Text(MetaBlock.string),
              TextButton(
                onPressed: _bottomLinks[1].launch,
                child: Text(_bottomLinks[1].text),
              ),
            ])
          ],
        ),
      ),
    );
  }

  Widget _buildRouteTile(
    BuildContext context, {
    required String id,
    required IconData icon,
    required String route,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      key: Key('setting.$id'),
      leading: Icon(icon),
      trailing: const Icon(Icons.navigate_next_outlined),
      onTap: () => context.pushNamed(route),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}

class _HeaderInfoList extends StatelessWidget {
  const _HeaderInfoList();

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<Menu>();
    final attrs = context.watch<OrderAttributes>();

    return SizedBox(
      height: 152,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: [
          _buildItem(
            id: 'menu1',
            context: context,
            title: menu.items.fold<int>(0, (v, e) => e.length + v),
            subtitle: '產品',
            route: Routes.menu,
            query: {'mode': 'products'},
          ),
          const SizedBox(width: 16),
          _buildItem(
            id: 'menu2',
            context: context,
            title: menu.length,
            subtitle: '種類',
            route: Routes.menu,
          ),
          const SizedBox(width: 16),
          _buildItem(
            id: 'order_attrs',
            context: context,
            title: attrs.length,
            subtitle: '顧客設定',
            route: Routes.orderAttr,
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required String id,
    required BuildContext context,
    required int title,
    required String subtitle,
    required String route,
    Map<String, String> query = const <String, String>{},
  }) {
    const borderRadius = BorderRadius.all(Radius.circular(20));
    final theme = Theme.of(context);

    return ElevatedButton(
      key: Key('setting_header.$id'),
      style: const ButtonStyle(
        fixedSize: MaterialStatePropertyAll(Size.square(128)),
        padding: MaterialStatePropertyAll(EdgeInsets.zero),
        // shadowColor: MaterialStatePropertyAll(Colors.transparent),
        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: Colors.transparent),
        )),
      ),
      onPressed: () => context.pushNamed(route, queryParameters: query),
      child: Ink(
        width: 128,
        height: 128,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: theme.gradientColors,
            tileMode: TileMode.clamp,
          ),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(title.toString(), style: theme.textTheme.headlineMedium),
          Text(subtitle, style: theme.textTheme.bodyMedium),
        ]),
      ),
    );
  }
}

const _bottomLinks = <LinkifyData>[
  LinkifyData('Privacy Policy',
      'https://evan361425.github.io/flutter-pos-system/PRIVACY_POLICY/'),
  LinkifyData(
      'License', 'https://evan361425.github.io/flutter-pos-system/LICENSE/'),
];
