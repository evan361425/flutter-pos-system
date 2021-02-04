import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/models/menu_model.dart';
import 'package:possystem/routes.dart';
import 'package:provider/provider.dart';

class Body extends StatelessWidget {
  final SlidableController _slidableController = SlidableController();

  @override
  Widget build(BuildContext context) {
    var menu = Provider.of<MenuModel>(context);
    menu ??= MenuModel({});

    return Container(
      padding: EdgeInsets.all(defaultPadding / 2),
      margin: EdgeInsets.all(defaultMargin / 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListView.separated(
        itemCount: menu.length,
        itemBuilder: (context, index) => _catalogBuilder(context, menu[index]),
        separatorBuilder: (context, index) => Divider(
          height: 5,
          thickness: 5,
          color: null,
        ),
      ),
    );
  }

  Widget _catalogBuilder(BuildContext context, CatalogModel catalog) {
    return Slidable(
      controller: _slidableController,
      actionPane: SlidableDrawerActionPane(),
      child: Container(
        child: ListTile(
          title: Text(catalog.name),
          subtitle: Text('5 products'),
          onTap: () => Navigator.of(context).pushNamed(
            Routes.menu_catalog_add,
            arguments: catalog,
          ),
        ),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Theme.of(context).secondaryHeaderColor),
          ],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          icon: Icons.delete,
          onTap: () => print('Delete'),
        ),
      ],
    );
  }
}
