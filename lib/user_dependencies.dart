import 'package:flutter/material.dart';
import 'package:possystem/models/repository/quantity_index_model.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/models/user_model.dart';
import 'package:possystem/services/authentication.dart';
import 'package:possystem/services/database.dart';
import 'package:provider/provider.dart';

/// This class is mainly to help with creating user dependent object that
/// need to be available by all downstream widgets.
/// Thus, this widget builder is a must to live above [MaterialApp].
/// As we rely on uid to decide which main screen to display (eg: Home or Sign In),
/// this class will helps to create all providers needed that depends on
/// the user logged data uid.
class UserDependencies extends StatelessWidget {
  final Widget Function(BuildContext, AsyncSnapshot<UserModel>) builder;
  final Database Function(String uid) databaseBuilder;

  const UserDependencies({
    Key key,
    @required this.builder,
    @required this.databaseBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var auth = context.watch<Authentication>();
    return StreamBuilder<UserModel>(
      stream: auth?.user,
      builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
        if (!snapshot.hasData) return builder(context, snapshot);

        final user = snapshot.data;

        Database.service = databaseBuilder(user.uid);

        /// For any other Provider services that rely on user data can be
        /// added to the following MultiProvider list.
        /// Once a user has been detected, a re-build will be initiated.
        return MultiProvider(
          providers: [
            Provider<UserModel>.value(value: user),
            ChangeNotifierProvider(create: (_) => MenuModel()),
            ChangeNotifierProvider(create: (_) => StockModel()),
            ChangeNotifierProvider(create: (_) => QuantityIndexModel()),
          ],
          builder: (context, child) => builder(context, snapshot),
        );
      },
    );
  }
}
