import 'package:flutter/material.dart';
import 'package:possystem/app_localizations.dart';
import 'package:possystem/models/user_model.dart';
import 'package:possystem/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class BackendScreen extends StatefulWidget {
  @override
  _BackendScreenState createState() => _BackendScreenState();
}

class _BackendScreenState extends State<BackendScreen> implements WidgetsBindingObserver {
  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NavigationProvider>(
      create: (_) => NavigationProvider(),
      builder: _scaffold,
    );
  }

  Widget _scaffold(BuildContext context, _) {
    final navigation = Provider.of<NavigationProvider>(context);
    final user = Provider.of<UserModel>(context);

    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Center(
          child: Text(
            Trans.of(context).t(navigation.page),
            style: Theme.of(context).textTheme.headline4,
          ),
        ),
        actions: <Widget>[
          IconButton(
            padding: EdgeInsets.only(right: 30.0),
            onPressed: () => print('Search'),
            icon: Icon(Icons.search),
            iconSize: 30.0,
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(user.displayName),
              accountEmail: Text(user.email),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text(Trans.of(context).t('menu')),
              onTap: () {
                Navigator.of(context).pop();
                navigation.page = 'menu';
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text(Trans.of(context).t('setting')),
              onTap: () {
                Navigator.of(context).pop();
                navigation.page = 'setting';
              },
            ),
          ],
        ),
      ),
      body: Consumer<NavigationProvider>(
        builder: (context, navigationProvider, _) => WillPopScope(
          onWillPop: () async => false,
          child: navigationProvider.body,
        ),
      ),
    );
  }

  @override
  void didChangeAccessibilityFeatures() => setState(() {});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  @override
  void didChangeLocales(List<Locale> locale) {}

  @override
  void didChangeMetrics() {}

  @override
  void didChangePlatformBrightness() {}

  @override
  void didChangeTextScaleFactor() {}

  @override
  void didHaveMemoryPressure() {}

  @override
  Future<bool> didPopRoute() {
    // TODO: implement didPopRoute
    throw UnimplementedError();
  }

  @override
  Future<bool> didPushRoute(String route) {
    // TODO: implement didPushRoute
    throw UnimplementedError();
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    // TODO: implement didPushRouteInformation
    throw UnimplementedError();
  }
}
