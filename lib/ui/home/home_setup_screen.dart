import 'package:flutter/material.dart';
import 'package:possystem/components/linkify.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/debug/random_gen_order.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

class HomeSetupScreen extends StatefulWidget {
  final TutorialInTab? tab;

  const HomeSetupScreen({
    Key? key,
    this.tab,
  }) : super(key: key);

  @override
  State<HomeSetupScreen> createState() => _HomeSetupScreenState();
}

class _HomeSetupScreenState extends State<HomeSetupScreen> {
  final antOrderAttr = Tutorial.buildAnt();
  final antExporter = Tutorial.buildAnt();
  final antGaffer = Tutorial.buildAnt();

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
            Tutorial(
              id: 'home.menu',
              ant: antGaffer,
              startNow: false,
              message: '現在就趕緊來設定菜單吧！',
              ants: [
                antOrderAttr,
                antExporter,
                antGaffer,
              ],
              shape: TutorialShape.rect,
              disable: Menu.instance.isNotEmpty,
              child: _buildRouteTile(
                id: 'menu',
                icon: Icons.collections_outlined,
                route: Routes.menu,
                title: S.menuTitle,
              ),
            ),
            Tutorial(
              ant: antExporter,
              id: 'home.exporter',
              title: '檔案匯出',
              message: '這裡是用來匯出菜單、庫存等資訊的地方。',
              shape: TutorialShape.rect,
              child: _buildRouteTile(
                id: 'exporter',
                icon: Icons.upload_file_outlined,
                route: Routes.exporter,
                title: S.exporterTitle,
              ),
            ),
            Tutorial(
              ant: antOrderAttr,
              id: 'home.order_attr',
              title: '顧客設定',
              message: '這裡可以設定顧客資訊，例如：\n'
                  '內用，加價一成；\n'
                  '外帶，維持原價。',
              shape: TutorialShape.rect,
              child: _buildRouteTile(
                id: 'order_attrs',
                icon: Icons.assignment_ind_outlined,
                route: Routes.orderAttr,
                title: S.orderAttributeTitle,
              ),
            ),
            _buildRouteTile(
              id: 'quantities',
              icon: Icons.exposure_outlined,
              route: Routes.quantities,
              title: S.quantityTitle,
            ),
            _buildRouteTile(
              id: 'feature_request',
              icon: Icons.lightbulb_outlined,
              route: Routes.featureRequest,
              title: S.featureRequestTitle,
            ),
            _buildRouteTile(
              id: 'setting',
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

  @override
  void initState() {
    super.initState();

    widget.tab?.bindAnt(antGaffer, startNow: true);
  }

  Widget _buildRouteTile({
    required String id,
    required IconData icon,
    required String route,
    required String title,
  }) {
    return ListTile(
      key: Key('home_setup.$id'),
      leading: Icon(icon),
      trailing: const Icon(Icons.navigate_next_outlined),
      onTap: () => Navigator.of(context).pushNamed(route),
      title: Text(title),
    );
  }
}

class _HeaderInfoList extends StatelessWidget {
  const _HeaderInfoList({Key? key}) : super(key: key);

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
  }) {
    const borderRadius = BorderRadius.all(Radius.circular(20));
    final theme = Theme.of(context);

    return ElevatedButton(
      style: const ButtonStyle(
        fixedSize: MaterialStatePropertyAll(Size.square(128)),
        padding: MaterialStatePropertyAll(EdgeInsets.zero),
        // shadowColor: MaterialStatePropertyAll(Colors.transparent),
        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: Colors.transparent),
        )),
      ),
      onPressed: () => Navigator.of(context).pushNamed(route),
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

const _privacyPolicy =
    'https://evan361425.github.io/flutter-pos-system/PRIVACY_POLICY/';
const _license = 'https://evan361425.github.io/flutter-pos-system/LICENSE/';
