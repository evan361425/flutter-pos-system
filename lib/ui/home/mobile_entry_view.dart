import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/footer.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/debug/debug_page.dart';
import 'package:possystem/helpers/setup_example.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';
import 'package:spotlight_ant/spotlight_ant.dart';

class MobileEntryView extends StatefulWidget {
  const MobileEntryView({super.key});

  @override
  State<MobileEntryView> createState() => _MobileEntryViewState();
}

class _MobileEntryViewState extends State<MobileEntryView> with AutomaticKeepAliveClientMixin {
  final GlobalKey<_TutorialCheckboxListTileState> _tutorialOrderAttrs = GlobalKey();
  final GlobalKey<_TutorialCheckboxListTileState> _tutorialMenu = GlobalKey();

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
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
          below: _TutorialCheckboxListTile(key: _tutorialMenu, title: S.menuTutorialCreateExample),
          spotlightBuilder: const SpotlightRectBuilder(),
          disable: Menu.instance.isNotEmpty,
          action: () async {
            if (_tutorialMenu.currentState?.value == true) {
              await setupExampleMenu();
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
        _buildRouteTile(
          id: 'transit',
          icon: Icons.upload_file_sharp,
          route: Routes.transit,
          title: S.transitTitle,
          subtitle: S.transitDescription,
        ),
        Tutorial(
          id: 'home.order_attr',
          index: 1,
          title: S.orderAttributeTutorialTitle,
          message: S.orderAttributeTutorialContent,
          below: _TutorialCheckboxListTile(key: _tutorialOrderAttrs, title: S.orderAttributeTutorialCreateExample),
          spotlightBuilder: const SpotlightRectBuilder(),
          disable: OrderAttributes.instance.isNotEmpty,
          action: () async {
            if (_tutorialOrderAttrs.currentState?.value == true) {
              await setupExampleOrderAttrs();
            }
          },
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
          route: Routes.quantities,
          title: S.stockQuantityTitle,
          subtitle: S.stockQuantityDescription,
        ),
        _buildRouteTile(
          id: 'feature_request',
          icon: Icons.lightbulb_sharp,
          route: Routes.elf,
          title: S.settingElfTitle,
          subtitle: S.settingElfDescription,
        ),
        _buildRouteTile(
          id: 'setting',
          icon: Icons.settings_sharp,
          route: Routes.settings,
          title: S.settingFeatureTitle,
          subtitle: S.settingFeatureDescription,
        ),
        const Footer(),
      ]),
    );
  }

  @override
  bool get wantKeepAlive => true;

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
          Flexible(child: Text(subtitle, textAlign: TextAlign.center)),
        ]),
      ),
    );
  }
}

class _TutorialCheckboxListTile extends StatefulWidget {
  final String title;

  const _TutorialCheckboxListTile({super.key, required this.title});

  @override
  State<_TutorialCheckboxListTile> createState() => _TutorialCheckboxListTileState();
}

class _TutorialCheckboxListTileState extends State<_TutorialCheckboxListTile> {
  bool value = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: CheckboxListTile(
        value: value,
        onChanged: (v) => setState(() => value = v!),
        tileColor: Theme.of(context).primaryColor,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
