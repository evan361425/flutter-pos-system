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

class _IngredientSnapshot extends Snapshot {
  @override
  Map<String, Map<String, dynamic>> data() {
    return const {
      'i1': {
        'name': 'cheese',
        'currentAmount': 20.0,
        'warningAmount': 20.0,
        'alertAmount': 20.0,
        'lastAmount': 20.0,
      },
      'i2': {
        'name': 'bread',
      },
      'i3': {
        'name': 'vegetable',
      },
      'i4': {
        'name': 'some-other-very-long-name 👎👎👎',
      },
    };
  }
}

class _IngredientSetSnapshot extends Snapshot {
  @override
  Map<String, Map<String, dynamic>> data() {
    return const {
      'is1': {
        'name': 'less',
        'defaultProportion': 0.5,
      },
      'is2': {
        'name': 'more',
        'defaultProportion': 1.5,
      },
    };
  }
}

class _SearchSnapshot extends Snapshot {
  @override
  Map<String, List<String>> data() {
    return const {
      'ingredient': ['che', 'br'],
      'ingredient_set': ['l'],
    };
  }
}

class _MenuSnapshot extends Snapshot {
  @override
  Map<String, Map<String, dynamic>> data() {
    return const {
      'c1': {
        'name': 'burger',
        'index': 0,
        'products': {
          '0': {
            'name': 'cheeseburger',
            'price': 30,
            'cost': 20,
            'index': 0,
            'ingredients': {
              'i1': {
                'defaultAmount': 20,
                'additionalSets': {
                  'is1': {
                    'amount': 10,
                    'additionalPrice': 0,
                    'additionalCost': -5,
                  },
                  'is2': {
                    'amount': 30,
                    'additionalPrice': 10,
                    'additionalCost': 5,
                  },
                },
              },
              'i2': {
                'defaultAmount': 1,
              },
              'i3': {
                'defaultAmount': 1,
              },
              'i4': {
                'defaultAmount': 1,
              }
            },
          },
          '1': {
            'name': 'hamburger',
            'price': 50,
            'index': 1,
            'ingredients': {}
          },
          '2': {
            'name': 'kamburger',
            'price': 50,
            'index': 2,
            'ingredients': {}
          },
          '3': {
            'name':
                'some-other-very-long-name-product-some-other-very-long-name-product-some-other-very-long-name-product-',
            'price': 30,
            'index': 3,
            'ingredients': {}
          },
          '4': {'name': 'product1', 'price': 30, 'index': 4, 'ingredients': {}},
          '5': {'name': 'product2', 'price': 30, 'index': 5, 'ingredients': {}},
          '6': {'name': 'product6', 'price': 30, 'index': 6, 'ingredients': {}},
          '7': {
            'name': '😂product4',
            'price': 30,
            'index': 7,
            'ingredients': {}
          },
          '8': {'name': '產品五', 'price': 30, 'index': 8, 'ingredients': {}},
          '9': {
            'name': '😂product6',
            'price': 30,
            'index': 9,
            'ingredients': {}
          },
          '10': {
            'name': '😂product7',
            'price': 30,
            'index': 10,
            'ingredients': {}
          },
          '11': {
            'name': '😂product8',
            'price': 30,
            'index': 11,
            'ingredients': {}
          },
          '12': {
            'name': '😂product9',
            'price': 30,
            'index': 12,
            'ingredients': {}
          },
          '13': {
            'name': '😂product.1',
            'price': 30,
            'index': 13,
            'ingredients': {}
          },
          '14': {
            'name': '😂product.2',
            'price': 30,
            'index': 14,
            'ingredients': {}
          },
        },
      },
      'c2': {
        'name': 'sandwitch',
        'index': 1,
        'products': {
          '15': {
            'name': 'c-sandwitch',
            'price': 30,
            'cost': 20,
            'index': 0,
            'ingredients': {
              'i1': {'defaultAmount': 20, 'additionalSets': {}}
            }
          },
        },
      },
      'c3': {
        'name': 'drink',
        'index': 2,
      }
    };
  }
}

class _MockDatabase extends Database<Snapshot> {
  final String uid;
  _MockDatabase({@required this.uid});

  @override
  Future<Snapshot> get(Collections collection) {
    if (collection == Collections.menu) {
      return Future.delayed(Duration(seconds: 0), () => _MenuSnapshot());
    } else if (collection == Collections.ingredient) {
      return Future.delayed(Duration(seconds: 0), () => _IngredientSnapshot());
    } else if (collection == Collections.search_history) {
      return Future.delayed(Duration(seconds: 0), () => _SearchSnapshot());
    } else {
      // } else if (collection == Collections.ingredient_sets) {
      return Future.delayed(
          Duration(seconds: 0), () => _IngredientSetSnapshot());
    }
  }

  @override
  Future<Snapshot> set(Collections collection, Map<String, dynamic> data) {
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

abstract class Snapshot {
  Map<String, dynamic> data();
}
