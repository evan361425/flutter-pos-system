import 'package:flutter/material.dart';
import 'package:possystem/components/backend/page.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/components/backend/appbar.dart';
import 'package:possystem/components/backend/bottom_navbar.dart';

class CustomerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackendAppBar(context, Local.of(context).t('customer')),
      bottomNavigationBar: BackendBottomNavBar(BackendBottomNavs.customer),
      body: BackendPage(
        child: Center(
          child: Text(
            'Customer',
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
      ),
    );
  }
}
