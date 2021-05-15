import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:possystem/my_app.dart';
import 'package:possystem/providers/currency_provider.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:possystem/services/database.dart';
import 'package:possystem/services/in_memory.dart';
import 'package:provider/provider.dart';

void main() {
  // https://stackoverflow.com/questions/57689492/flutter-unhandled-exception-servicesbinding-defaultbinarymessenger-was-accesse
  WidgetsFlutterBinding.ensureInitialized();
  // Status bar style on Android/iOS
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle());

  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  ).then((_) {
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
          ChangeNotifierProvider<CurrencyProvider>(
            create: (_) => CurrencyProvider(),
          ),
          Provider(create: (_) => Logger()),
        ],
        child: MyApp(),
      ),
    );
  });
}

final DefaultData = <Collections, Map<String, dynamic>>{
  Collections.stock: {
    'updatedTime': '2021-03-20 00:00:00.000',
    'ingredients': {
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
        'name': 'some-other-very-long-namesome-other-very-long-name 👎👎👎',
      },
      'i5': {'name': 'i5'},
      'i6': {'name': 'i6'},
      'i7': {'name': 'i7'},
      'i8': {'name': 'i8'},
      'i9': {'name': 'i9'},
      'ii5': {'name': 'i5'},
      'ii6': {'name': 'i6'},
      'ii7': {'name': 'i7'},
      'ii8': {'name': 'i8'},
      'ii9': {'name': 'i9'},
    }
  },
  Collections.menu: {
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
              'amount': 20,
              'quantities': {
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
              'amount': 1,
              'quantities': {
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
                'is3': {
                  'amount': 1,
                  'additionalPrice': -5,
                  'additionalCost': -10,
                },
                'is4': {
                  'amount': 50,
                  'additionalPrice': 20,
                  'additionalCost': 10,
                },
              },
            },
            'i3': {
              'amount': 1,
            },
            'i4': {
              'amount': 1,
            }
          },
        },
        '1': {'name': 'hamburger', 'price': 50, 'index': 1, 'ingredients': {}},
        '2': {
          'name': 'kamburger',
          'price': 500000,
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
        '7': {'name': '😂product4', 'price': 30, 'index': 7, 'ingredients': {}},
        '8': {'name': '產品五', 'price': 30, 'index': 8, 'ingredients': {}},
        '9': {'name': '😂product6', 'price': 30, 'index': 9, 'ingredients': {}},
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
            'i1': {'amount': 20}
          }
        },
      },
    },
    'c3': {
      'name': 'drink',
      'index': 2,
    }
  },
  // Collections.order_history: {},
  // Collections.order_stash: {},
  Collections.quantities: {
    'is1': {
      'name': 'less',
      'defaultProportion': 0.5,
    },
    'is2': {
      'name': 'more',
      'defaultProportion': 1.5,
    },
    'is3': {
      'name': 'really less',
      'defaultProportion': 0.1,
    },
    'is4': {
      'name': 'really more',
      'defaultProportion': 3,
    },
  },
  Collections.search_history: {
    'ingredient': ['che', 'br'],
    'quantity': ['l'],
  },
  Collections.stock_batch: {
    'sb1': {
      'name': 'Costco',
      'data': {
        'i1': 1.2,
        'i2': 3,
        'i4': 5,
      },
    },
    'sb2': {
      'name': '7-11',
    },
  },
};
