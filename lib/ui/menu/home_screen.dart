import 'package:flutter/material.dart';
import 'package:possystem/components/appbar/backend_appbar.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/widgets/body.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed(
            Routes.menu_catalog_add,
          );
        },
      ),
      body: Body(),
    );
  }
}
