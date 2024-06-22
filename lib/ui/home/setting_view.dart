import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/linkify.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/debug/debug_page.dart';
import 'package:possystem/helpers/setup_menu.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';
import 'package:spotlight_ant/spotlight_ant.dart';

class SettingView extends StatefulWidget {
  final int? tabIndex;

  const SettingView({super.key, this.tabIndex});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> with AutomaticKeepAliveClientMixin {
  late final TutorialInTab? tab;
  final GlobalKey<_TutorialCreateExampleMenuListTileState> _tutorialCheckbox = GlobalKey();

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return TutorialWrapper(
      tab: tab,
      child: Scaffold(
        floatingActionButton: (Cache.instance.get<bool>('tutorial.home.order') ?? false)
            ? null
            : Tutorial(
                id: 'home.order',
                // 0 if menu tutorial is not shown (only index 0 will trigger tutorial)
                index: Menu.instance.isNotEmpty ? 0 : 1,
                spotlightBuilder: const SpotlightRectBuilder(borderRadius: 16.0),
                title: S.menuTutorialTitle,
                message: S.menuTutorialContent,
                child: FloatingActionButton.extended(
                  onPressed: null,
                  icon: const Icon(Icons.store_sharp),
                  label: Text(S.orderBtn),
                ),
              ),
        body: ListView(padding: const EdgeInsets.only(bottom: 76), children: [
          const _HeaderInfoList(),
          if (!isProd)
            ListTile(
              key: const Key('setting.debug'),
              leading: const Icon(Icons.bug_report_sharp),
              title: const Text('Debug'),
              subtitle: const Text('For developer only'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DebugPage()),
              ),
            ),
          Tutorial(
            id: 'home.menu',
            index: 0,
            title: S.menuTutorialTitle,
            message: S.menuTutorialContent,
            below: _TutorialCreateExampleMenuListTile(key: _tutorialCheckbox),
            spotlightBuilder: const SpotlightRectBuilder(),
            disable: Menu.instance.isNotEmpty,
            action: () async {
              if (_tutorialCheckbox.currentState?.createExampleMenu == true) {
                await helpSetupMenu();
              } else {
                await context.pushNamed(Routes.menu);
              }
            },
            child: _buildRouteTile(
              id: 'menu',
              icon: Icons.collections_sharp,
              route: Routes.menu,
              title: S.menuTitle,
              subtitle: S.menuSubtitle,
            ),
          ),
          Tutorial(
            id: 'home.exporter',
            index: 3,
            title: S.transitTutorialTitle,
            message: S.transitTutorialContent,
            spotlightBuilder: const SpotlightRectBuilder(),
            child: _buildRouteTile(
              id: 'exporter',
              icon: Icons.upload_file_sharp,
              route: Routes.transit,
              title: S.transitTitle,
              subtitle: S.transitDescription,
            ),
          ),
          Tutorial(
            id: 'home.order_attr',
            index: 2,
            title: S.orderAttributeTutorialTitle,
            message: S.orderAttributeTutorialContent,
            spotlightBuilder: const SpotlightRectBuilder(),
            child: _buildRouteTile(
              id: 'order_attrs',
              icon: Icons.assignment_ind_sharp,
              route: Routes.orderAttr,
              title: S.orderAttributeTitle,
              subtitle: S.orderAttributeDescription,
            ),
          ),
          _buildRouteTile(
            id: 'quantity',
            icon: Icons.exposure_sharp,
            route: Routes.quantity,
            title: S.stockQuantityTitle,
            subtitle: S.stockQuantityDescription,
          ),
          _buildRouteTile(
            id: 'feature_request',
            icon: Icons.lightbulb_sharp,
            route: Routes.featureRequest,
            title: S.settingElfTitle,
            subtitle: S.settingElfDescription,
          ),
          _buildRouteTile(
            id: 'setting',
            icon: Icons.settings_sharp,
            route: Routes.features,
            title: S.settingFeatureTitle,
            subtitle: S.settingFeatureDescription,
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
        ]),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    tab = widget.tabIndex == null ? null : TutorialInTab(index: widget.tabIndex!, context: context);

    super.initState();
  }

  Widget _buildRouteTile({
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
            subtitle: S.menuProductHeaderInfo,
            route: Routes.menu,
            query: {'mode': 'products'},
          ),
          const SizedBox(width: 16),
          _buildItem(
            id: 'menu2',
            context: context,
            title: menu.length,
            subtitle: S.menuCatalogHeaderInfo,
            route: Routes.menu,
          ),
          const SizedBox(width: 16),
          _buildItem(
            id: 'order_attrs',
            context: context,
            title: attrs.length,
            subtitle: S.orderAttributeHeaderInfo,
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
        fixedSize: WidgetStatePropertyAll(Size.square(128)),
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
        // shadowColor: WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
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
          Text(subtitle, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _TutorialCreateExampleMenuListTile extends StatefulWidget {
  const _TutorialCreateExampleMenuListTile({super.key});

  @override
  State<_TutorialCreateExampleMenuListTile> createState() => _TutorialCreateExampleMenuListTileState();
}

class _TutorialCreateExampleMenuListTileState extends State<_TutorialCreateExampleMenuListTile> {
  bool createExampleMenu = true;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: createExampleMenu,
      onChanged: (v) => setState(() => createExampleMenu = v!),
      title: Text(S.menuTutorialCreateExample),
    );
  }
}

const _bottomLinks = <LinkifyData>[
  LinkifyData('Privacy Policy', 'https://evan361425.github.io/flutter-pos-system/PRIVACY_POLICY/'),
  LinkifyData('License', 'https://evan361425.github.io/flutter-pos-system/LICENSE/'),
];
