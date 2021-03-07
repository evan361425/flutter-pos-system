import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:possystem/models/user_model.dart';
import 'package:possystem/my_app.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:possystem/services/authentication.dart';
import 'package:possystem/services/database.dart';
import 'package:possystem/services/sign_in_method/sign_in_method.dart';
import 'package:provider/provider.dart';

void main() {
  // https://stackoverflow.com/questions/57689492/flutter-unhandled-exception-servicesbinding-defaultbinarymessenger-was-accesse
  WidgetsFlutterBinding.ensureInitialized();
  // Status bar style on Android/iOS
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle());

  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  ).then((_) async {
    runApp(
      /// Why use provider?
      /// https://stackoverflow.com/questions/57157823/provider-vs-inheritedwidget
      MultiProvider(
        providers: [
          Provider(create: (_) => Logger()),
          ChangeNotifierProvider<Authentication>(
            create: (_) => _MockAuth(),
          ),
          ChangeNotifierProvider<ThemeProvider>(
            create: (_) => ThemeProvider(),
          ),
          ChangeNotifierProvider<LanguageProvider>(
            create: (_) => LanguageProvider(),
          ),
        ],
        child: MyApp(
          databaseBuilder: (uid) => _MockDatabase(uid: uid),
        ),
      ),
    );
  });
}

class _MenuSnapshot {
  Map<String, Map<String, dynamic>> data() {
    return {
      'burger': {
        'id': 1,
        'index': 0,
        'products': {
          'cheeseburger': {
            'id': 1,
            'price': 30,
            'cost': 20,
            'index': 0,
            'ingredients': {
              'cheese': {
                'defaultAmount': 20,
                'additionalSets': {
                  'less': {
                    'ammount': 10,
                    'additionalPrice': 0,
                    'additionalCost': -5,
                  },
                  'more': {
                    'ammount': 30,
                    'additionalPrice': 10,
                    'additionalCost': 5,
                  },
                },
              },
              'bread': {
                'defaultAmount': 1,
              },
              'vegetable': {
                'defaultAmount': 1,
              },
              'some-other-very-long-name 👎👎👎': {
                'defaultAmount': 1,
              }
            },
          },
          'hamburger': {'id': 1, 'price': 50, 'index': 1, 'ingredients': {}},
          'kamburger': {'id': 2, 'price': 50, 'index': 2, 'ingredients': {}},
          'some-other-very-long-name-product-some-other-very-long-name-product-some-other-very-long-name-product-':
              {'id': 3, 'price': 30, 'index': 3, 'ingredients': {}},
          'product1': {'id': 4, 'price': 30, 'index': 4, 'ingredients': {}},
          'product2': {'id': 5, 'price': 30, 'index': 5, 'ingredients': {}},
          'product3': {'id': 6, 'price': 30, 'index': 6, 'ingredients': {}},
          '😂product4': {'id': 7, 'price': 30, 'index': 7, 'ingredients': {}},
          '產品五': {'id': 8, 'price': 30, 'index': 8, 'ingredients': {}},
          '😂product6': {'id': 10, 'price': 30, 'index': 9, 'ingredients': {}},
          '😂product7': {'id': 11, 'price': 30, 'index': 10, 'ingredients': {}},
          '😂product8': {'id': 12, 'price': 30, 'index': 11, 'ingredients': {}},
          '😂product9': {'id': 13, 'price': 30, 'index': 12, 'ingredients': {}},
          '😂producs1': {'id': 14, 'price': 30, 'index': 13, 'ingredients': {}},
          '😂producs2': {'id': 15, 'price': 30, 'index': 14, 'ingredients': {}},
        },
      },
      'sandwitch': {
        'id': 2,
        'index': 1,
        'products': {
          'c-sandwitch': {'id': 1, 'price': 30, 'index': 0, 'ingredients': {}},
        },
      },
      'drink': {
        'id': 3,
        'index': 2,
      }
    };
  }
}

class _MockDatabase extends Database<_MenuSnapshot> {
  final String uid;
  _MockDatabase({@required this.uid});

  @override
  Future<_MenuSnapshot> get(Collections collection) {
    return Future.delayed(Duration(seconds: 0), () => _MenuSnapshot());
  }

  @override
  Future<_MenuSnapshot> set(Collections collection, Map<String, dynamic> data) {
    return Future.delayed(Duration(seconds: 0));
  }

  @override
  Future<void> update(Collections collection, Map<String, dynamic> data) {
    return Future.delayed(Duration(seconds: 0));
  }
}

class _MockAuth extends Authentication {
  final UserModel _user;

  _MockAuth()
      : _user = UserModel(
          uid: 'test-uid',
          email: 'test@email.com',
          displayName: 'Test User',
        ) {
    status = AuthStatus.Authenticated;
  }

  @override
  Future<UserModel> signIn(BuildContext context, SignInMethod method) async {
    status = AuthStatus.Authenticated;
    return _user;
  }

  @override
  Future<void> signOut() async {
    status = AuthStatus.Unauthenticated;
  }

  @override
  Stream<UserModel> get user async* {
    yield _user;
  }
}
