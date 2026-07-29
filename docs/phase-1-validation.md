# Phase 1 technical validation

## Scope

This branch validates an independently branded Android build of the upstream
POS project for Samsung phone and tablet testing.

## Implemented

- App identity: `Elbe-Jade POS`
- Android application ID and namespace: `com.elbejade.pos`
- Original Google Play/Fastlane publishing workflow removed
- Original Firebase Analytics, Crashlytics, Performance and Google sign-in
  runtime integration removed from the validation path
- Temporary Elbe-Jade icon installed
- Default currency changed to EUR with German number formatting
- German added as a selectable locale; phase 1 flows are translated and
  untranslated detail screens fall back to English
- A three-category catalog with exactly 20 seafood products is seeded on a
  fresh installation
- Flutter 3.41 configures compile SDK and target SDK 36 (Android 16)
- Android 12+ Bluetooth scan/connect permissions are declared

## Verified locally

- Dependency resolution succeeds using the public upstream mock package
- EUR formatting tests pass
- The example catalog test confirms 3 categories and 20 products
- Core code compiles in Flutter tests

## Known blocker: Bluetooth printing

The upstream app's real Bluetooth and receipt-printer implementation is in the
private `flutter-pos-packages` repository. The public
`flutter-pos-packages-mock` implementation does not scan, connect or print.
This validation build therefore keeps printing explicitly non-functional.
A successful receipt print must not be claimed until the printer layer is
reimplemented or the private dependency is legitimately supplied.

## Acceptance still requiring Samsung hardware

- Install the debug APK on a Samsung S25 Ultra running Android 16
- Install the same APK on a Samsung Tab S9+ and check portrait, landscape and
  split-screen layouts
- Create, stash, check out and review an order
- Export Excel, CSV and plain-text data and open the files
- Check German labels and EUR formatting on both screen sizes
- After a real printer implementation exists, pair and print on the intended
  Bluetooth printer
