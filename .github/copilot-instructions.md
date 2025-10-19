POS System use Flutter to build a cross-platform application.
It is designed to be well tested (mainly widget tests) and easy to maintain by
providing well structured code and clear comments.

## Code Standards

### Required Before Each Commit
- Run `make format` before committing any changes to ensure proper code formatting
- Run `make lint` to catch common issues and maintain code quality
- Run `make build-l10n` to update localization files if any text changes were made

### Development Flow
- Test: `make test`

## Repository Structure
- `android/`, `/ios`: Platform-specific code for Android and iOS
- `assets/`: Static assets like images and text files
- `lib/`: Main application code
  - `components/`: Reusable UI components, e.g., buttons, dialogs
  - `helpers/`: Utility functions and classes
  - `l10n/`: Generated files, should not be edited manually
  - `models/`: Data models that will be saved in the database or storage
  - `services/`: External services like database, authentication, etc.
    - `storage` is for document database in local
    - `database` is for SQL database in SQLite
  - `settings/`: Client feature settings and configurations
  - `ui/`: Screens and pages of the application
- `test/`: Unit and widget tests

## Key Guidelines
1. Responsive design for various screen sizes is usually designed by `components/dialog/ResponsiveDialog.dart`.
2. Internationalization (i18n) is first written in `assets/l10n/{lang}/*.yaml` files, then run `make build-l10n` to generate localization files.
  - Text key is defined by mapped keys in YAML files, like `S.helloWorldKey` will be `hello:\n  world:\n    key: "Hello World"`.
  - If need a description, use list not key-value, like: `key:\n  - "value"\n  - "description"`.
  - Use map in first element if using select mode, like: `key:\n  - key1: "value1"\n    key2: "value2"\n  - "description"` will generate ARB file as `{value, select, key1{value} key2{value} other{UNKNOWN}}`.
3. Maintain existing code structure and organization.
4. Write widget tests to fully cover new features and bug fixes.
5. Tests should be wrapping into one `testWidgets` function if they are in the same page and can be done in one flow.
   This helps to reduce the time of test execution.
6. No need to write document in `docs/` unless I told so.
