import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/backend/page.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/components/backend/appbar.dart';
import 'package:possystem/components/backend/bottom_navbar.dart';

class AnalysisScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackendAppBar(context, Local.of(context).t('analysis')),
      bottomNavigationBar: BackendBottomNavBar(BackendBottomNavs.analysis),
      body: BackendPage(
        child: Center(
          child: Text(
            'Analysis',
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
      ),
    );
  }
}
