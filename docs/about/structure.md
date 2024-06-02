# Architecture

We use [Flutter](https://flutter.dev) to write all application-related logic.
Flutter provides a wealth of resources for learning,
including complete applications like [Gallery](https://github.com/flutter/gallery)
and various [samples](https://github.com/flutter/samples).

Flutter uses [Skia](https://skia.org) as its graphics engine,
enabling direct interaction with the underlying OS on all platforms
(macOS, Linux, Windows, Web, iOS, Android).
This minimizes the need for platform-specific interfaces,
allowing a unified interface across multiple platforms.

Of course, in certain scenarios, specific platform configurations are required.
For example, iOS notifications need to be set up in XCode and [AppStoreConnect](http://appstoreconnect.apple.com).
However, the overall business logic and application design can be written directly using Flutter.

Flutter is a framework, and the language used to write it is [Dart](https://dart.dev).
Dart's style is similar to many object-oriented languages.
Personally, I find it no different from other languages,
mainly because it integrates well with IDEs, making it convenient to write.
The documentation is also extensive. Here are a few detailed articles worth reading:

- [10 good reasons why you should learn Dart](https://medium.com/hackernoon/10-good-reasons-why-you-should-learn-dart-4b257708a332)
- [Why Flutter uses Dart](https://hackernoon.com/why-flutter-uses-dart-dd635a054ebf)

If you want to try it out right away, you can play with their online [compiler](https://dartpad.dev/?null_safety=true).

## POS System Architecture on Flutter

This aims to help beginners understand the app architecture.

### Main Architecture

```text
.
├── assets/             - Various images, potentially fonts in the future
├── lib/                - Main logic
│   ├── components/     - Various UI helper components
│   ├── constants/      - Fixed standards, like colors, commonly used icons
│   ├── helpers/        - Commonly used functions, like Log
│   ├── l10n/           - In-app text and translations (only zh-TW)
│   ├── models/         - Objects, like products, ingredients, etc., interacting with Services rather than UI
│   ├── services/       - Tools for external communication, like DB
│   ├── settings/       - User-adjustable settings, like theme, language, appearance
│   ├── ui/             - Main app design
│   ├── main.dart       - Handles initialization of Services, Models, and Firebase
│   ├── my_app.dart     - Builds the main APP
│   ├── routes.dart     - Application routes
│   └── translator.dart - Avoids repetitive long translation object calls
└── test/               - Unit and component tests, mirroring lib/ structure
```

### Components

```text
components/                     - Various UI helper components
├── dialog/                     - Dialogs
│    ├── confirm_dialog         - Confirmation dialog
│    ├── delete_dialog          - Delete dialog
│    ├── single_text_dialog     - Text input dialog
│    └── slider_text_dialog     - Slider dialog with numerical attributes
├── mixin/                      - Helper components
│    └── item_modal             - Module for editing objects (e.g., products, ingredients)
├── models/                     - UI components related to objects
├── scaffold/                   - Scaffold components
│    ├── item_list_scaffold     - Used for settings, might move to setting_screen
│    └── reorderable_scaffold   - Reorderable scaffold
└── style/                      - Components not passing tests
     └── ...                    - Miscellaneous, not listed
```

### Constants

```text
constants/     - Fixed standards, like colors, commonly used icons
├── app_themes - Colors
├── constant   - Numeric standards, like padding, margin sizes
└── icons      - Commonly used icons
```

### Helpers

```text
helpers/          - Commonly used functions, like Log
├── exporter/     - API for exporting data
├── formater/     - Data formatting
├── launcher      - Opens browser on link click
├── logger        - Output, including to Firebase Analytics
├── util          - Miscellaneous
└── validator     - Input validation tools, e.g., text must be numeric and greater than one
```

### Models

```text
models/                          - Objects, like products, ingredients, etc., interacting with Services rather than UI
├── constumer/                   - Customer settings
│    ├── customer_setting_option - Customer setting options
│    └── customer_setting        - Customer settings
├── menu/                        - Menu
│    ├── catalog                 - Product categories
│    ├── product_ingredient      - Product ingredients
│    ├── product_quantity        - Product quantities
│    └── product                 - Products
├── objects/                     - I/O objects
│    ├── cashier_object          - Cashier objects
│    ├── customer_object         - Customer setting objects
│    ├── menu_object             - Menu objects
│    ├── order_attributeobject   - Order attribute objects (customer settings)
│    ├── order_object            - Order objects
│    └── stock_object            - Stock objects
├── order/                       - Orders
│    └── order_product           - Order product settings
├── repository/                  - Object repositories
│    ├── cart_ingredients        - Manages ingredients in orders
│    ├── cart                    - Cart repository
│    ├── cashier                 - Cashier repository
│    ├── customer_settings       - Customer settings repository
│    ├── menu                    - Menu repository
│    ├── quantities              - Quantities repository
│    ├── replenisher             - Replenisher repository
│    ├── seller                  - Seller repository, handles DB order submissions
│    └── stock                   - Stock repository (inventory)
├── stock/                       - Stock
│    ├── ingredient              - Stock ingredients
│    ├── quantity                - Stock ingredient quantities
│    └── replenishment           - Stock replenishments
├── model_object                 - Base object
├── model                        - Base model
├── repository                   - Base repository
└── xfile                        - API for filesystem
```

### Services

```text
services/               - Tools for external communication, like DB
├── auth                - Authentication logic, user login, etc.
├── cache               - User settings and behavior tracking, like tutorial completion
├── database            - Records multiple data points, SQLite
├── database_migrations - Database version integration records
├── image_dumper        - Manages image access
└── storage             - Records high-variance data like menus and stock, NoSQL
```

### Settings

```text
settings/                    - User-adjustable settings, like theme, language
├── cashier_warning          - Cashier warning settings
├── collect_event            - User error message collection settings
├── currency                 - Currency settings (pre-built for future use)
├── language                 - Language settings
├── order_awakening          - Screen on/off settings during ordering
├── order_outlook            - Ordering appearance settings
├── order_product_axis_count - Ordering appearance settings
├── theme                    - Themes (daylight and dark)
├── setting                  - Settings interface
└── settings_provider        - Manages all settings interfaces
```

### UI

Basic framework:

```text
feature/             - Specific features
├── ...              - Sub-features, if any, will be listed
├── widgets/         - Helper objects for features, not listed below
└── feature_screen   - Feature framework, not listed below
```

Interfaces:

```text
ui/                    - Main app design
├── analysis/          - Order analysis
├── cashier/           - Cashier
│    └── changer       - Change money
├── customer/          - Customer settings
├── home/              - Home
├── menu/              - Menu
│    ├── catalog/      - Product categories
│    └── product/      - Products
├── order/             - Order
│    ├── cart          - Cart
│    └── cashier       - Checkout
├── setting/           - Settings
└── stock/             - Stock
     ├── quantity      - Ingredient quantities
     └── replenishment - Replenishment
```
