import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/models/repository/quantity_repo.dart';
import 'package:possystem/my_app.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:provider/provider.dart';

import 'models/repository/stock_model.dart';

void main() {
  // https://stackoverflow.com/questions/57689492/flutter-unhandled-exception-servicesbinding-defaultbinarymessenger-was-accesse
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  ).then((_) async {
    runApp(
      /// Why use provider?
      /// https://stackoverflow.com/questions/57157823/provider-vs-inheritedwidget
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(
            create: (_) => ThemeProvider(),
          ),
          ChangeNotifierProvider<LanguageProvider>(
            create: (_) => LanguageProvider(),
          ),
          ChangeNotifierProvider<MenuModel>(
            create: (_) => MenuModel(),
          ),
          ChangeNotifierProvider<StockModel>(
            create: (_) => StockModel(),
          ),
          ChangeNotifierProvider<QuantityRepo>(
            create: (_) => QuantityRepo(),
          ),
          Provider(create: (_) => Logger()),
        ],
        child: MyApp(),
      ),
    );
  });
}
