import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:logger/logger.dart';
import 'package:possystem/components/appbar/backend.dart';
import 'package:possystem/models/menu_model.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/firestore_database.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackendAppBar('menu').appBar,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed(
            Routes.menu_catalog_add,
          );
        },
      ),
      body: WillPopScope(
        onWillPop: () async => false,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final firestore = Provider.of<FirestoreDatabase>(context, listen: false);

    return StreamBuilder<DocumentSnapshot>(
      stream: firestore.getStream(Collections.menu),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          Provider.of<Logger>(context).e(snapshot.error);
          return Text('error..');
        }

        if (snapshot.hasData) {
          if (snapshot.data.exists) {
            return _buildCatalogs(MenuModel.fromMap(snapshot.data.data()));
          }

          var menu = MenuModel.playground();
          firestore.add(Collections.menu, menu.toMap());

          return _buildCatalogs(menu);
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildCatalogs(MenuModel menu) {
    final SlidableController slidableController = SlidableController();

    return ListView.separated(
      itemCount: menu.catalogs.length,
      itemBuilder: (context, index) {
        return Slidable(
          controller: slidableController,
          actionPane: SlidableDrawerActionPane(),
          child: Container(
            child: ListTile(
              title: Text(menu.catalogs[index].name),
              subtitle: Text('5 products'),
              onTap: () => Navigator.of(context).pushNamed(
                Routes.menu_catalog_add,
                arguments: menu.catalogs[index],
              ),
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
      },
      separatorBuilder: (context, index) {
        return Divider(height: 0.5);
      },
    );
  }
}
