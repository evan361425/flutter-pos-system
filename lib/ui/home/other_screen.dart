import 'package:flutter/material.dart';
import 'package:possystem/components/style/route_tile.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';

class OtherScreen extends StatelessWidget {
  const OtherScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _HeaderInfoList(),
            RouteTile(
              key: Key('other.menu'),
              icon: Icons.collections_outlined,
              route: Routes.menu,
              title: '設定菜單',
            ),
            RouteTile(
              key: Key('other.customer'),
              icon: Icons.assignment_ind_outlined,
              route: Routes.customer,
              title: '設定份量',
            ),
            RouteTile(
              key: Key('other.quantities'),
              icon: Icons.exposure_outlined,
              route: Routes.quantities,
              title: '設定份量',
            ),
            RouteTile(
              key: Key('other.setting'),
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

class _HeaderInfoList extends StatelessWidget {
  const _HeaderInfoList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0, 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          _HeaderInfo(
            title: Menu.instance.items.fold<int>(0, (v, e) => e.length + v),
            subtitle: '項產品',
          ),
          _HeaderInfo(
            title: Menu.instance.length,
            subtitle: '項種類',
          ),
          _HeaderInfo(
            title: CustomerSettings.instance.length,
            subtitle: '項顧客設定',
          ),
        ]),
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
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 128,
      height: 128,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title.toString(),
              style: textTheme.headline4,
            ),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}
