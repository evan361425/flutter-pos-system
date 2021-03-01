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
          ChangeNotifierProvider<Authentication>(
            create: (_) => _MockAuth(),
          ),
          Provider(create: (_) => Logger()),
        ],
        child: MyApp(
          databaseBuilder: (_, uid) => _MockDatabase(uid: uid),
        ),
      ),
    );
  });
}

class _MenuSnapshot {
  Map<String, Map<String, dynamic>> data() {
    return {
      'burger': {
        'index': 0,
        'products': {
          'cheeseburger': {
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
          'hamburger': {'price': 50, 'index': 1, 'ingredients': {}},
          'kamburger': {'price': 50, 'index': 2, 'ingredients': {}},
          'some-other-very-long-name-product-some-other-very-long-name-product-some-other-very-long-name-product-':
              {'price': 30, 'index': 3, 'ingredients': {}},
          'product1': {'price': 30, 'index': 4, 'ingredients': {}},
          'product2': {'price': 30, 'index': 5, 'ingredients': {}},
          'product3': {'price': 30, 'index': 6, 'ingredients': {}},
          '😂product4': {'price': 30, 'index': 7, 'ingredients': {}},
          '產品五': {'price': 30, 'index': 8, 'ingredients': {}}
        },
      },
      'sandwitch': {
        'index': 1,
        'products': {
          'cheese-sandwitch': {'price': 30, 'index': 0, 'ingredients': {}},
        },
      },
      'drink': {
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
