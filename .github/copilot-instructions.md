POS System use Flutter to build a cross-platform application.
It is designed to be well tested (mainly widget tests) and easy to maintain.

## Key Guidelines
1. Keep conciseness and keep maintain existing code structure.
2. Code only, no compliments.
1. Responsive design for various screen sizes is usually designed by @components/dialog/ResponsiveDialog.dart.
2. Internationalization (i18n) is first written in @assets/l10n/{lang}/*.yaml files, then run `make build-l10n` to generate localization files.
  - Text key is defined by mapped keys in YAML files, like `S.helloWorldKey` will be `hello:\n  world:\n    key: "Hello World"`.
  - If need a description, use list not key-value, like: `key:\n  - "value"\n  - "description"`.
  - Use map in first element if using select mode, like: `key:\n  - key1: "value1"\n    key2: "value2"\n  - "description"` will generate ARB file as `{value, select, key1{value} key2{value} other{UNKNOWN}}`.
4. Write widget tests to fully cover new features and bug fixes.
5. Tests should be wrapping into one `testWidgets` function if they are in the same page and can be done in one flow.
   This helps to reduce the time of test execution.
6. No need to write document in `docs/` unless I told so.

## Code Standards

### Required Before Each Commit
- Run `make format` before committing any changes to ensure proper code formatting
- Run `make lint` to catch common issues and maintain code quality
- Run `make build-l10n` to update localization files if any text changes were made

### Development Flow
- Single test case: `flutter test test/$path/$filename.dart --name="$test_description"`
  Add coverage by append `--coverage` onto above command
- Single test file: `flutter test test/$path/$filename.dart`
  Add coverage by append `--coverage` onto above command
- All component tests: `make test`

## Repository Structure
- `android/`, `/ios`: Platform-specific code for Android and iOS
- `assets/`: Static assets like images and text files
- `lib/`: Main application code
  - `components/` Various UI helper components
  - `constants/` Fixed standards, like colors, commonly used icons
  - `helpers/` Commonly used functions, like Log
  - `l10n/` In-app text and translations (only zh-TW)
  - `models/` Objects, like products, ingredients, etc., interacting with Services rather than UI
  - `services/` Tools for external communication, like DB
    - `storage` Records high-variance data like menus and stock, NoSQL
    - `database` Records multiple data points, SQLite
  - `settings/` User-adjustable settings, like theme, language, appearance
  - `ui/` Main app design
  - `main.dart` Handles initialization of Services, Models, and Firebase
  - `my_app.dart` Builds the main APP
  - `routes.dart` Application routes
  - `translator.dart` Avoids repetitive long translation object calls
- `test/` Unit and widget tests
