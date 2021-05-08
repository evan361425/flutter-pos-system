import 'package:flutter/material.dart';
import 'package:possystem/routes.dart';

class IconActions extends StatelessWidget {
  const IconActions({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.extent(
      maxCrossAxisExtent: 150.0,
      children: [
        _LabeledIcon(
          icon: Icons.collections_outlined,
          label: '菜單',
          route: Routes.menu,
        ),
        _LabeledIcon(
          icon: Icons.assignment_ind_outlined,
          label: '客戶資訊',
          route: '',
        ),
        _LabeledIcon(
          icon: Icons.exposure_outlined,
          label: '份量',
          route: Routes.stockQuantity,
        ),
        _LabeledIcon(
          icon: Icons.import_export_outlined,
          label: '匯出匯入',
          route: '',
        ),
        _LabeledIcon(
          icon: Icons.settings_outlined,
          label: '設定',
          route: '',
        ),
      ],
    );
  }
}

class _LabeledIcon extends StatelessWidget {
  const _LabeledIcon({
    Key key,
    @required this.icon,
    @required this.label,
    @required this.route,
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
          Text(label, style: TextStyle(color: theme.textTheme.caption.color)),
        ],
      ),
    );
  }
}
