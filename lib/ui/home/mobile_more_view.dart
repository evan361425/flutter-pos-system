import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/footer.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

class MobileMoreView extends StatefulWidget {
  const MobileMoreView({super.key});

  @override
  State<MobileMoreView> createState() => _MobileMoreViewState();
}

class _MobileMoreViewState extends State<MobileMoreView> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: ListView(padding: const EdgeInsets.only(bottom: 76), children: [
        const _HeaderInfoList(),
        if (!isProd)
          _buildRouteTile(
            id: 'debug',
            icon: Icons.bug_report_outlined,
            route: 'debug',
            title: 'Debug',
            subtitle: 'For developer only',
          ),
        OrderAttrTutorial(
          child: _buildRouteTile(
            id: 'orderAttributes',
            icon: Icons.assignment_ind_outlined,
            route: Routes.orderAttr,
            title: S.orderAttributeTitle,
            subtitle: S.orderAttributeDescription,
          ),
        ),
        MenuTutorial(
          child: _buildRouteTile(
            id: 'menu',
            icon: Icons.collections_outlined,
            route: Routes.menu,
            title: S.menuTitle,
            subtitle: S.menuSubtitle,
          ),
        ),
        _buildRouteTile(
          id: 'printers',
          icon: Icons.print_outlined,
          route: Routes.printer,
          title: S.printerTitle,
          subtitle: S.printerDescription,
          beta: true,
        ),
        _buildRouteTile(
          id: 'transit',
          icon: Icons.upload_file_outlined,
          route: Routes.transit,
          title: S.transitTitle,
          subtitle: S.transitDescription,
        ),
        _buildRouteTile(
          id: 'stockQuantities',
          icon: Icons.exposure_outlined,
          route: Routes.quantities,
          title: S.stockQuantityTitle,
          subtitle: S.stockQuantityDescription,
        ),
        _buildRouteTile(
          id: 'elf',
          icon: Icons.lightbulb_outlined,
          route: Routes.elf,
          title: S.settingElfTitle,
          subtitle: S.settingElfDescription,
        ),
        _buildRouteTile(
          id: 'settings',
          icon: Icons.settings_outlined,
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
    bool beta = false,
  }) {
    return ListTile(
      key: Key('home.$id'),
      leading: Icon(icon),
      trailing: const Icon(Icons.navigate_next_outlined),
      onTap: () => context.goNamed(route),
      title: beta
          ? Row(children: [
              Text(title),
              const SizedBox(width: 8),
              const Badge(label: Text('Beta')),
            ])
          : Text(title),
      subtitle: Text(subtitle),
    );
  }
}

class _HeaderInfoList extends StatelessWidget {
  const _HeaderInfoList();

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<Menu>();
    final printers = context.watch<Printers>();
    final attrs = context.watch<OrderAttributes>();

    return SizedBox(
      height: 152,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: [
          _buildItem(
            id: 'products',
            context: context,
            title: menu.items.fold<int>(0, (v, e) => e.length + v),
            subtitle: S.menuProductHeaderInfo,
            route: Routes.menu,
            query: {'mode': 'products'},
          ),
          const SizedBox(width: 16),
          _buildItem(
            id: 'printers',
            context: context,
            title: printers.length,
            subtitle: S.printerHeaderInfo,
            route: Routes.printer,
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
      key: Key('more_header.$id'),
      style: const ButtonStyle(
        fixedSize: WidgetStatePropertyAll(Size.square(128)),
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
        // shadowColor: WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: Colors.transparent),
        )),
      ),
      onPressed: () => context.goNamed(route, queryParameters: query),
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
