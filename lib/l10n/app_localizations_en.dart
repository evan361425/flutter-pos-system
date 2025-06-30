// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingTab => 'Settings';

  @override
  String settingVersion(String version) {
    return 'Version: $version';
  }

  @override
  String settingWelcome(String name) {
    return 'Hi, $name';
  }

  @override
  String get settingLogoutBtn => 'Log Out';

  @override
  String get settingElfTitle => 'Suggestions';

  @override
  String get settingElfDescription => 'Provide feedback using Google Forms';

  @override
  String get settingElfContent =>
      'Feel like something\'s missing here?\nFeel free to [give suggestions](https://forms.gle/s8V5SXuqhA1u3zmt7).\nYou can also check out [upcoming features](https://github.com/evan361425/flutter-pos-system/milestones).';

  @override
  String get settingFeatureTitle => 'Other Settings';

  @override
  String get settingFeatureDescription => 'Appearance, Language, Tips';

  @override
  String get settingThemeTitle => 'Theme';

  @override
  String settingThemeName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'dark': 'Dark Mode',
        'light': 'Light Mode',
        'system': 'Follow System',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get settingLanguageTitle => 'Language';

  @override
  String get settingCheckoutWarningTitle => 'Cash Registry Warnings';

  @override
  String settingCheckoutWarningName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'showAll': 'Show All',
        'onlyNotEnough': 'Show Only When Not Enough',
        'hideAll': 'Hide All',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String settingCheckoutWarningTip(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'showAll':
            'Show warning when using smaller denominations to give change.\nFor example, if \$5 is not enough, start using 5 \$1 bills for change.',
        'onlyNotEnough': 'Show warning when cash registry not enough money.',
        'hideAll': 'Won\'t display any warnings during ordering.',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get settingOrderAwakeningTitle => 'Keep Screen On During Ordering';

  @override
  String get settingOrderAwakeningDescription =>
      'If disabled, the screen will turn off based on system settings during ordering.';

  @override
  String get settingReportTitle => 'Collect Error Messages and Events';

  @override
  String get settingReportDescription =>
      'Send error messages when the app encounters issues, helping the app improve';

  @override
  String get stockTab => 'Inventory';

  @override
  String stockUpdatedAt(DateTime updatedAt) {
    final intl.DateFormat updatedAtDateFormat =
        intl.DateFormat.MMMEd(localeName);
    final String updatedAtString = updatedAtDateFormat.format(updatedAt);

    return 'Last Purchased: $updatedAtString';
  }

  @override
  String get stockIngredientEmptyBody =>
      'Once ingredients are added, you can start tracking their inventory!';

  @override
  String get stockIngredientTitleCreate => 'Add Ingredient';

  @override
  String get stockIngredientTitleUpdate => 'Edit Ingredient';

  @override
  String get stockIngredientTitleUpdateAmount => 'Edit Inventory';

  @override
  String get stockIngredientTutorialTitle => 'Add Ingredient';

  @override
  String get stockIngredientTutorialContent =>
      'Ingredients help us track product inventory.\n\nYou can add ingredients in \"Menu\"\nand then manage inventory here.';

  @override
  String stockIngredientDialogDeletionContent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Deleting this ingredient will also remove it from $count products',
      zero: 'No products currently use this ingredient',
    );
    return '$_temp0';
  }

  @override
  String stockIngredientProductsCount(int count) {
    return '$count products using it';
  }

  @override
  String get stockIngredientNameLabel => 'Ingredient Name';

  @override
  String get stockIngredientNameHint => 'e.g., Cheese';

  @override
  String get stockIngredientNameErrorRepeat => 'Ingredient name already exists';

  @override
  String get stockIngredientAmountLabel => 'Current Amount';

  @override
  String get stockIngredientAmountMaxLabel => 'Maximum Amount';

  @override
  String get stockIngredientAmountMaxHelper =>
      'Setting this value helps you see how much of the ingredient is being used.\nLeave blank or don\'t fill it in, and the value will automatically be set each time inventory is increased.';

  @override
  String get stockIngredientRestockTitle =>
      'The amount of ingredient you can restock each time.\nFor example, if 30 units of cheese cost 100 dollars,\nfill in \"30\" for \"Restock Unit\" and \"100\" for \"Restock Price.\"\n\nThis helps you quickly restock by price.';

  @override
  String get stockIngredientRestockPriceLabel => 'Restock Price';

  @override
  String get stockIngredientRestockQuantityLabel => 'Restock Unit';

  @override
  String stockIngredientRestockDialogTitle(String quantity, String price) {
    return 'Each $quantity costs $price dollars';
  }

  @override
  String get stockIngredientRestockDialogSubtitle =>
      'Please enter the purchase price';

  @override
  String get stockIngredientRestockDialogQuantityTab => 'Quantity';

  @override
  String get stockIngredientRestockDialogQuantityBtn => 'Use Quantity';

  @override
  String get stockIngredientRestockDialogQuantityLabel => 'Current Amount';

  @override
  String get stockIngredientRestockDialogQuantityHelper =>
      'If Maximum Amount is not set, every time increase the amount will be considered as the Maximum Amount';

  @override
  String get stockIngredientRestockDialogPriceTab => 'Price';

  @override
  String get stockIngredientRestockDialogPriceBtn => 'Use Price';

  @override
  String get stockIngredientRestockDialogPriceLabel => 'Total Price';

  @override
  String get stockIngredientRestockDialogPriceEmptyBody =>
      'Set the restock price first to calculate the amount directly from the price.\n';

  @override
  String get stockIngredientRestockDialogPriceOldAmount => 'Origin';

  @override
  String get stockReplenishmentButton => 'Replenish';

  @override
  String get stockReplenishmentEmptyBody =>
      'Purchasing helps you quickly adjust ingredient inventory';

  @override
  String get stockReplenishmentTitleList => 'Replenishment';

  @override
  String get stockReplenishmentTitleCreate => 'Add Replenishment';

  @override
  String get stockReplenishmentTitleUpdate => 'Edit Replenishment';

  @override
  String stockReplenishmentMetaAffect(int count) {
    return 'Affects $count Ingredients';
  }

  @override
  String get stockReplenishmentNever => 'Never Replenished';

  @override
  String get stockReplenishmentApplyPreview => 'Preview';

  @override
  String get stockReplenishmentApplyConfirmButton => 'Apply';

  @override
  String get stockReplenishmentApplyConfirmTitle => 'Apply Replenishment?';

  @override
  String stockReplenishmentApplyConfirmColumn(String value) {
    String _temp0 = intl.Intl.selectLogic(
      value,
      {
        'name': 'Name',
        'amount': 'Amount',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get stockReplenishmentApplyConfirmHint =>
      'After apply, following ingredients will be adjusted';

  @override
  String get stockReplenishmentTutorialTitle => 'Replenishment';

  @override
  String get stockReplenishmentTutorialContent =>
      'Through Replenishment, you no longer need to set the inventory of each ingredient one by one.\nSet up Replenishment now and adjust multiple ingredients at once!';

  @override
  String get stockReplenishmentNameLabel => 'Replenishment Name';

  @override
  String get stockReplenishmentNameHint => 'e.g., Costco Shopping';

  @override
  String get stockReplenishmentNameErrorRepeat =>
      'Replenishment name already exists';

  @override
  String get stockReplenishmentIngredientsDivider => 'Ingredients';

  @override
  String get stockReplenishmentIngredientsHelper =>
      'Click to set the quantity of different ingredients to be purchased';

  @override
  String get stockReplenishmentIngredientAmountHint =>
      'Set the amount to increase/decrease';

  @override
  String get stockQuantityTitle => 'Quantities';

  @override
  String get stockQuantityDescription => 'Half Sugar, Low Sugar, etc.';

  @override
  String get stockQuantityTitleCreate => 'Add Quantity';

  @override
  String get stockQuantityTitleUpdate => 'Edit Quantity';

  @override
  String get stockQuantityEmptyBody =>
      'Quantity allows for quick adjustments to the amount of ingredients, such as:\nHalf Sugar, Low Sugar.';

  @override
  String stockQuantityMetaProportion(num proportion) {
    final intl.NumberFormat proportionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String proportionString = proportionNumberFormat.format(proportion);

    return 'Default Ratio: $proportionString';
  }

  @override
  String stockQuantityDialogDeletionContent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Deleting this quantity will also remove it from $count product ingredients',
      zero: 'No product ingredients currently use this quantity',
    );
    return '$_temp0';
  }

  @override
  String get stockQuantityNameLabel => 'Quantity Name';

  @override
  String get stockQuantityNameHint => 'e.g., Small or Large';

  @override
  String get stockQuantityNameErrorRepeat => 'Quantity name already exists';

  @override
  String get stockQuantityProportionLabel => 'Default Ratio';

  @override
  String get stockQuantityProportionHelper =>
      'Applied when this quantity is used for an ingredient.\n\nFor example:\nif this quantity is \"Large\" and the default ratio is \"1.5\",\nand there\'s a product \"Cheeseburger\" with the ingredient \"Cheese,\"\nwhich uses \"2\" units of cheese per burger,\nwhen adding this quantity,\nthe quantity of \"Cheese\" will automatically be set to \"3\" (2 * 1.5).\n\nIf set to \"1,\" there\'s no effect.\n\nIf set to \"0,\" the ingredient won\'t be used.';

  @override
  String get printerTitle => 'Printer Management';

  @override
  String get printerDescription => 'Bluetooth Connection, Printer Settings';

  @override
  String get printerHeaderInfo => 'Printers';

  @override
  String get printerTitleCreate => 'Add Printer';

  @override
  String get printerTitleUpdate => 'Edit Printer';

  @override
  String get printerTitleSettings => 'Format Settings';

  @override
  String get printerBtnConnect => 'Connect';

  @override
  String get printerBtnDisconnect => 'Disconnect';

  @override
  String get printerBtnTestPrint => 'Test Print';

  @override
  String get printerBtnRetry => 'Re-Connect';

  @override
  String get printerBtnPrint => 'Print';

  @override
  String get printerStatusSuccess => 'Printer connected';

  @override
  String get printerStatusConnecting => 'Connecting';

  @override
  String get printerStatusStandby => 'Not connected';

  @override
  String get printerStatusPrinted => 'Print complete';

  @override
  String printerStatusName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'good': 'All Good',
        'writeFailed': 'Last Print Failed',
        'paperNotFound': 'Paper Not Found',
        'tooHot': 'Printer Overheated',
        'lowBattery': 'Low Battery',
        'printing': 'Printing',
        'unknown': 'Unknown',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String printerSignalName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'good': 'Good',
        'normal': 'Normal',
        'weak': 'Weak',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get printerScanIng => 'Scanning for Bluetooth Devices...';

  @override
  String printerScanCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Devices Found',
      one: '$countString Device Found',
    );
    return '$_temp0';
  }

  @override
  String get printerScanRetry => 'Re-scan';

  @override
  String get printerScanNotFound => 'Not Found?';

  @override
  String get printerErrorNotSelect => 'No device selected';

  @override
  String get printerErrorNotSupportTitle => 'Device Not Compatible';

  @override
  String get printerErrorNotSupportContent =>
      'This device is currently unsupported.\n\n[Contact Us](mailto:evanlu361425@gmail.com) for assistance.';

  @override
  String get printerErrorBluetoothOff => 'Bluetooth is off';

  @override
  String get printerErrorDisconnected => 'Printer is disconnected';

  @override
  String get printerErrorTimeout => 'Printer connection timeout';

  @override
  String get printerErrorCanceled => 'Printer connection request interrupted';

  @override
  String get printerErrorTimeoutMore =>
      'Try the following:\n• Check if the device is powered on (usually will flash)\n• Ensure the device is within range\n• Restart Bluetooth';

  @override
  String get printerNameLabel => 'Printer Name';

  @override
  String get printerNameHint => 'e.g., Kitchen\'s Printer';

  @override
  String printerNameHelper(String address) {
    return 'Location: $address';
  }

  @override
  String get printerAutoConnLabel => 'Auto-Connect';

  @override
  String get printerAutoConnHelper =>
      'Automatically connect when entering the order page';

  @override
  String get printerMetaConnected => 'Connected';

  @override
  String get printerMetaExist => 'Existing, cannot add';

  @override
  String get printerMetaHelper =>
      'Enable Bluetooth and keep the printer nearby';

  @override
  String get printerSettingsTitle => 'Printer Format Settings';

  @override
  String get printerSettingsPaddingLabel => 'Narrow Spacing';

  @override
  String get printerSettingsPaddingHelper =>
      'Reduces paper between receipts; need caution when tearing';

  @override
  String get printerSettingsMore => 'More Settings Coming Soon!';

  @override
  String get printerReceiptTitle => 'Receipt';

  @override
  String get printerReceiptColumnName => 'Item';

  @override
  String get printerReceiptColumnPrice => 'U/P';

  @override
  String get printerReceiptColumnCount => 'QTY';

  @override
  String get printerReceiptColumnTotal => 'TOT';

  @override
  String get printerReceiptColumnTime => 'Time';

  @override
  String get printerReceiptDiscountLabel => 'Discount';

  @override
  String get printerReceiptDiscountOrigin => 'Origin';

  @override
  String get printerReceiptAddOnsLabel => 'Add-Ons';

  @override
  String get printerReceiptAddOnsAdjustment => 'Adj';

  @override
  String get printerReceiptTotal => 'Total';

  @override
  String get printerReceiptPaid => 'Paid';

  @override
  String get printerReceiptPrice => 'Price';

  @override
  String get printerReceiptChange => 'Change';

  @override
  String get printerInfoTitle => 'Printer Information';

  @override
  String get printerInfoName => 'Name';

  @override
  String get printerInfoAddress => 'Location';

  @override
  String get printerInfoSignal => 'Signal';

  @override
  String get printerInfoStatus => 'Status';

  @override
  String get transitTitle => 'Data Transfer';

  @override
  String get transitDescription =>
      'Importing and Exporting Store Information and Orders';

  @override
  String get transitDescriptionCsv =>
      'Commas Separate Values, lightweight to export and import data, compatible with most software.';

  @override
  String get transitDescriptionExcel =>
      'Excel allow offline export and import, easy to integrate with Google Sheets and Microsoft Excel.';

  @override
  String get transitDescriptionGoogleSheet =>
      'Google Sheets is a powerful mini-database. After exporting, it can be customized for various analyses!';

  @override
  String get transitDescriptionPlainText => 'Quick check, quick share.';

  @override
  String get transitMethodTitle => 'Please Select Transfer Method';

  @override
  String transitMethodName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'googleSheet': 'Google Sheets',
        'plainText': 'Plain Text',
        'excel': 'Excel',
        'csv': 'CSV',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String transitCatalogTitle(Object name) {
    return 'Use $name to Do What?';
  }

  @override
  String transitCatalogName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'exportOrder': 'Export Order Records',
        'exportModel': 'Export Store Information',
        'importModel': 'Import Store Information',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String transitCatalogHelper(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'exportOrder': 'Export order info for detailed statistical analysis.',
        'exportModel':
            'Export store info to backup menu, inventory, etc., to third-party locations.',
        'importModel': 'Synchronize info to this device.',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String transitModelName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'menu': 'Menu',
        'stock': 'Inventory',
        'quantities': 'Quantities',
        'replenisher': 'Replenisher',
        'orderAttr': 'Customer Settings',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String transitOrderName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'basic': 'Order',
        'attr': 'Customer Details',
        'product': 'Product Details',
        'ingredient': 'Ingredient Details',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get transitOrderSettingTitle => 'Order Export Settings';

  @override
  String transitOrderSettingMetaOverwrite(String value) {
    String _temp0 = intl.Intl.selectLogic(
      value,
      {
        'true': 'Will overwrite',
        'false': 'Won\'t overwrite',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String transitOrderSettingMetaTitlePrefix(String value) {
    String _temp0 = intl.Intl.selectLogic(
      value,
      {
        'true': 'Has date prefix',
        'false': 'No date prefix',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get transitOrderSettingOverwriteLabel => 'Overwrite Sheet';

  @override
  String get transitOrderSettingOverwriteHint =>
      'Overwriting the sheet will start exporting from the first row.';

  @override
  String get transitOrderSettingTitlePrefixLabel => 'Add Date Prefix';

  @override
  String get transitOrderSettingTitlePrefixHint =>
      'Add a date prefix to the sheet name, for example, \"0101 - 0131 Order Data\".';

  @override
  String get transitOrderSettingRecommendCombination =>
      'When not overwriting and using append instead, it\'s recommended not to add a date prefix to the form name.';

  @override
  String transitOrderMetaRange(String range) {
    return 'Orders for $range';
  }

  @override
  String transitOrderMetaRangeDays(int days) {
    return 'Data for $days Days';
  }

  @override
  String transitOrderCapacityTitle(Object size) {
    return 'Estimated Capacity: $size';
  }

  @override
  String get transitOrderCapacityContent =>
      'High capacity may cause execution errors. It\'s recommended to perform in batches and not export too many records at once.';

  @override
  String get transitOrderCapacityOk => 'Capacity Okay';

  @override
  String get transitOrderCapacityWarn => 'Capacity Warning';

  @override
  String get transitOrderCapacityDanger => 'Capacity Danger';

  @override
  String transitOrderItemTitle(DateTime date) {
    final intl.DateFormat dateDateFormat =
        intl.DateFormat('MMM d HH:mm:ss', localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String transitOrderItemMetaProductCount(int count) {
    return 'Product Count: $count';
  }

  @override
  String transitOrderItemMetaPrice(String price) {
    return 'Total Price: $price';
  }

  @override
  String get transitOrderItemDialogTitle => 'Order Details';

  @override
  String get transitExportTab => 'Export';

  @override
  String get transitExportFileDialogTitle => 'Select Export Location';

  @override
  String get transitExportBasicBtnCsv => 'Export CSV files';

  @override
  String get transitExportBasicBtnExcel => 'Export Excel file';

  @override
  String get transitExportBasicBtnGoogleSheet => 'Upload to Google Sheets';

  @override
  String get transitExportBasicBtnPlainText => 'Copy';

  @override
  String get transitExportBasicFileName => 'POS System Data';

  @override
  String get transitExportBasicSuccessCsv => 'Exported successfully';

  @override
  String get transitExportBasicSuccessExcel => 'Exported successfully';

  @override
  String get transitExportBasicSuccessGoogleSheet => 'Uploaded successfully';

  @override
  String get transitExportBasicSuccessPlainText => 'Copied successfully';

  @override
  String get transitExportBasicSuccessActionGoogleSheet => 'Open';

  @override
  String get transitExportOrderTitleCsv => 'Export CSV files';

  @override
  String get transitExportOrderTitleExcel => 'Export Excel file';

  @override
  String get transitExportOrderTitleGoogleSheet => 'Upload to Google Sheets';

  @override
  String get transitExportOrderTitlePlainText => 'Copy';

  @override
  String get transitExportOrderSubtitleCsv =>
      'Will have multiple files with different types of data.';

  @override
  String get transitExportOrderSubtitleExcel =>
      'Single file with many sheets each having different types of data.';

  @override
  String get transitExportOrderSubtitleGoogleSheet =>
      'Upload needs network connection and request might be throttled by Google.\nIf the upload fails, please try again later or use other methods to export.\n';

  @override
  String get transitExportOrderSubtitlePlainText =>
      'Simple text format, should be used for small data.';

  @override
  String get transitExportOrderFileName => 'POS System Orders';

  @override
  String get transitExportOrderProgressGoogleSheetOverwrite =>
      'Overwriting existing data';

  @override
  String get transitExportOrderProgressGoogleSheetAppend =>
      'Appending data to the exist sheet';

  @override
  String get transitExportOrderWarningMemoryGoogleSheet =>
      'The capacity here represents the amount consumed by network transmission, the actual cloud memory occupied may be only one percent of this value.\nFor detailed capacity limit explanations, please refer to [this document](https://developers.google.com/sheets/api/limits#quota).\n';

  @override
  String get transitExportOrderSuccessCsv => 'Exported successfully';

  @override
  String get transitExportOrderSuccessExcel => 'Exported successfully';

  @override
  String get transitExportOrderSuccessGoogleSheet => 'Uploaded successfully';

  @override
  String get transitExportOrderSuccessPlainText => 'Copied successfully';

  @override
  String get transitExportOrderSuccessActionGoogleSheet => 'Open';

  @override
  String get transitImportTab => 'Import';

  @override
  String get transitImportBtnCsv => 'Select .csv file';

  @override
  String get transitImportBtnExcel => 'Select .xlsx file';

  @override
  String get transitImportBtnGoogleSheet => 'Select spreadsheet';

  @override
  String get transitImportBtnPlainTextAction => 'Click to paste text';

  @override
  String get transitImportBtnPlainTextHint => 'Paste copied text here';

  @override
  String get transitImportBtnPlainTextHelper =>
      'After pasting the text, it will analyze and determine the type of information to import.\nCopying too much text may cause system crash.\n';

  @override
  String get transitImportModelSelectionLabel => 'Data Type';

  @override
  String get transitImportModelSelectionAll => 'All';

  @override
  String get transitImportModelSelectionHint =>
      'Select the type of data first to import the corresponding data.';

  @override
  String get transitImportModelSelectionPlainTextHint => 'Enter text to import';

  @override
  String get transitImportProgressGoogleSheetStart =>
      'Importing data from spreadsheet';

  @override
  String get transitImportProgressGoogleSheetPrepare =>
      'Fetching spreadsheet metadata';

  @override
  String transitImportErrorBasicColumnCount(int columns) {
    return 'Insufficient data, $columns columns required';
  }

  @override
  String get transitImportErrorBasicDuplicate =>
      'This line will be ignored as the same item appeared earlier';

  @override
  String get transitImportErrorCsvPickFile => 'Failed to pick file';

  @override
  String get transitImportErrorExcelPickFile => 'Failed to pick file';

  @override
  String get transitImportErrorGoogleSheetFetchDataTitle =>
      'Unable to fetch data from spreadsheet';

  @override
  String get transitImportErrorGoogleSheetFetchDataHelper =>
      'Don\'t worry, it\'s usually easy to solve!\nPossible reasons include:\n• Unstable network conditions;\n• POS system not authorized to read sheets;\n• Misspelled spreadsheet ID, try copying the entire URL and pasting it;\n• The spreadsheet has been deleted.';

  @override
  String transitImportErrorGoogleSheetMissingTitle(Object name) {
    return 'No data found for sheet $name';
  }

  @override
  String get transitImportErrorGoogleSheetMissingHelper =>
      'Don\'t worry, it\'s usually easy to solve!\nPossible reasons include:\n• The spreadsheet doesn\'t have the sheets we want;\n• Unstable network conditions;\n• POS system not authorized to read sheets;\n• Misspelled spreadsheet ID, try copying the entire URL and pasting it;\n• The spreadsheet has been deleted.';

  @override
  String transitImportErrorPreviewNotFound(Object name) {
    return 'Can\'t find \'$name\' in the data';
  }

  @override
  String get transitImportErrorPlainTextNotFound =>
      'This text cannot match any corresponding service. Please refer to the exported text content.';

  @override
  String get transitImportSuccess => 'Imported successfully';

  @override
  String get transitImportPreviewConfirmTitle => 'Import the data?';

  @override
  String get transitImportPreviewConfirmContent =>
      'Note: After importing, the data not shown will be removed. Please confirm before executing!';

  @override
  String get transitImportPreviewConfirmBtn => 'Import Data';

  @override
  String get transitImportPreviewConfirmVerify => 'Verify';

  @override
  String transitImportPreviewConfirmHint(int count) {
    return 'Still have $count types of data not verified.\nIf the data is incorrect, please cancel the operation and re-import after correction.\n';
  }

  @override
  String transitImportPreviewIngredientMetaAmount(num amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return 'Amount: $amountString';
  }

  @override
  String transitImportPreviewIngredientMetaMaxAmount(int exist, num value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    String _temp0 = intl.Intl.pluralLogic(
      exist,
      locale: localeName,
      other: 'Max Value: $valueString',
      zero: 'Not Set',
    );
    return '$_temp0';
  }

  @override
  String get transitImportPreviewIngredientConfirm =>
      'Note: After importing, ingredients not shown won\'t be removed to avoid affecting the \"Menu\" status.';

  @override
  String get transitImportPreviewQuantityConfirm =>
      'Note: After importing, quantities not shown won\'t be removed to avoid affecting the \"Menu\" status.';

  @override
  String transitImportColumnStatus(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'normal': '(Normal)',
        'staged': '(New)',
        'stagedIng': '(New Ingredient)',
        'stagedQua': '(New Quantity)',
        'updated': '(Updated)',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get transitFormatFieldProductIngredientTitle =>
      'Ingredient Information';

  @override
  String get transitFormatFieldProductIngredientNote =>
      'Information of all product ingredients, format as follows:\n- Ingredient 1, Default usage amount\n  + Quantity a, Additional usage amount, Additional price, Additional cost\n  + Quantity b, Additional usage amount, Additional price, Additional cost\n- Ingredient 2, Default usage amount';

  @override
  String get transitFormatFieldReplenishmentTitle => 'Replenishment Amount';

  @override
  String get transitFormatFieldReplenishmentNote =>
      'The amount of specific ingredients during each replenishment, format as follows:\n- Ingredient 1, Replenishment amount\n- Ingredient 2, Replenishment amount';

  @override
  String get transitFormatFieldAttributeOptionTitle =>
      'Customer Setting Options';

  @override
  String get transitFormatFieldAttributeOptionNote =>
      '\"Options\" will have different meanings depending on the type of customer settings, format as follows:\n- Option 1, Is default, Option value\n- Option 2, Is default, Option value';

  @override
  String get transitFormatFieldOrderTs => 'Timestamp';

  @override
  String get transitFormatFieldOrderTime => 'Time';

  @override
  String get transitFormatFieldOrderPrice => 'Price';

  @override
  String get transitFormatFieldOrderProductPrice => 'Product Price';

  @override
  String get transitFormatFieldOrderPaid => 'Paid';

  @override
  String get transitFormatFieldOrderCost => 'Cost';

  @override
  String get transitFormatFieldOrderProfit => 'Profit';

  @override
  String get transitFormatFieldOrderItemCount => 'Item Count';

  @override
  String get transitFormatFieldOrderTypeCount => 'Type Count';

  @override
  String get transitFormatFieldOrderAttributeTitle => 'Order Customer Settings';

  @override
  String get transitFormatFieldOrderAttributeHeaderTs => 'Timestamp';

  @override
  String get transitFormatFieldOrderAttributeHeaderName => 'Setting Category';

  @override
  String get transitFormatFieldOrderAttributeHeaderOption => 'Option';

  @override
  String get transitFormatFieldOrderProductTitle => 'Order Product Details';

  @override
  String get transitFormatFieldOrderProductHeaderTs => 'Timestamp';

  @override
  String get transitFormatFieldOrderProductHeaderName => 'Product';

  @override
  String get transitFormatFieldOrderProductHeaderCatalog => 'Category';

  @override
  String get transitFormatFieldOrderProductHeaderCount => 'Quantity';

  @override
  String get transitFormatFieldOrderProductHeaderPrice => 'Single Price';

  @override
  String get transitFormatFieldOrderProductHeaderCost => 'Single Cost';

  @override
  String get transitFormatFieldOrderProductHeaderOrigin => 'Original Price';

  @override
  String get transitFormatFieldOrderIngredientTitle =>
      'Order Ingredient Details';

  @override
  String get transitFormatFieldOrderIngredientHeaderTs => 'Timestamp';

  @override
  String get transitFormatFieldOrderIngredientHeaderName => 'Ingredient';

  @override
  String get transitFormatFieldOrderIngredientHeaderQuantity => 'Quantity';

  @override
  String get transitFormatFieldOrderIngredientHeaderAmount => 'Amount';

  @override
  String get transitFormatFieldOrderExpandableHint => 'See next table';

  @override
  String transitFormatTextOrderPrice(
      int hasProducts, String price, String productsPrice) {
    String _temp0 = intl.Intl.pluralLogic(
      hasProducts,
      locale: localeName,
      other: 'Total price \$$price, $productsPrice of them are product price.',
      zero: 'Total price \$$price.',
    );
    return '$_temp0';
  }

  @override
  String transitFormatTextOrderMoney(String paid, String cost) {
    return 'Paid \$$paid, cost \$$cost.';
  }

  @override
  String transitFormatTextOrderProductCount(
      int count, int setCount, String products) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'There are $count products ($setCount types of set) including:\n$products.',
      one: 'There is 1 product details are:\n$products.',
      zero: 'There is no product.',
    );
    return '$_temp0';
  }

  @override
  String transitFormatTextOrderProduct(int hasIngredient, String product,
      String catalog, int count, String price, String ingredients) {
    String _temp0 = intl.Intl.pluralLogic(
      hasIngredient,
      locale: localeName,
      other:
          '$count of $product ($catalog), total price is \$$price, ingredients are $ingredients',
      zero:
          '$count of $product ($catalog), total price is \$$price, no ingredient settings',
    );
    return '$_temp0';
  }

  @override
  String transitFormatTextOrderIngredient(
      num amount, String ingredient, String quantity) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: '$ingredient ($quantity), used $amountString',
      zero: '$ingredient ($quantity)',
    );
    return '$_temp0';
  }

  @override
  String get transitFormatTextOrderNoQuantity => 'default quantity';

  @override
  String transitFormatTextOrderOrderAttribute(String options) {
    return 'Customer\'s $options.';
  }

  @override
  String transitFormatTextOrderOrderAttributeItem(String name, String option) {
    return '$name is $option';
  }

  @override
  String transitFormatTextMenuHeader(int catalogs, int products) {
    return 'This menu has $catalogs categories, $products products.';
  }

  @override
  String get transitFormatTextMenuHeaderPrefix => 'This menu has';

  @override
  String transitFormatTextMenuCatalog(
      String index, String catalog, String details) {
    return 'Category $index is called $catalog and $details.';
  }

  @override
  String transitFormatTextMenuCatalogDetails(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'it has $count products',
      one: 'it has one product',
      zero: 'it has no product',
    );
    return '$_temp0';
  }

  @override
  String transitFormatTextMenuProduct(
      String index, String name, String price, String cost, String details) {
    return 'Product $index is called $name, with price at \$$price, cost \$$cost and $details';
  }

  @override
  String transitFormatTextMenuProductDetails(
      int count, String names, String details) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'it has $count ingredients: $names.\nEach product requires $details.',
      one: 'it has one ingredient: $names.\nEach product requires $details.',
      zero: 'it has no ingredient.',
    );
    return '$_temp0';
  }

  @override
  String transitFormatTextMenuIngredient(
      String amount, String name, String details) {
    return '$amount of $name and $details';
  }

  @override
  String transitFormatTextMenuIngredientDetails(int count, String quantities) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'it also has $count different quantities $quantities',
      one: 'it also has one different quantity $quantities',
      zero: 'it is unable to adjust quantity',
    );
    return '$_temp0';
  }

  @override
  String transitFormatTextMenuQuantity(
      String amount, String price, String cost) {
    return 'quantity $amount with additional price \$$price and cost \$$cost';
  }

  @override
  String transitFormatTextStockHeader(int count) {
    return 'The inventory has $count ingredients in total.';
  }

  @override
  String get transitFormatTextStockHeaderPrefix => 'The inventory has';

  @override
  String transitFormatTextStockIngredient(
      String index, String name, String amount, String details) {
    return 'Ingredient at $index is called $name, with $amount amount$details.';
  }

  @override
  String transitFormatTextStockIngredientMaxAmount(int exist, String max) {
    String _temp0 = intl.Intl.pluralLogic(
      exist,
      locale: localeName,
      other: ', with a maximum of $max pieces',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String transitFormatTextStockIngredientRestockPrice(
      int exist, String quantity, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      exist,
      locale: localeName,
      other: ' and $quantity units of it cost \$$price to replenish',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String transitFormatTextQuantitiesHeader(int count) {
    return '$count quantities have been set.';
  }

  @override
  String get transitFormatTextQuantitiesHeaderSuffix =>
      'quantities have been set.';

  @override
  String transitFormatTextQuantitiesQuantity(
      String index, String name, String prop) {
    return 'Quantity at $index is called $name, which defaults to multiplying ingredient quantity by $prop.';
  }

  @override
  String transitFormatTextReplenisherHeader(int count) {
    return '$count replenishment methods have been set.';
  }

  @override
  String get transitFormatTextReplenisherHeaderSuffix =>
      'replenishment methods have been set.';

  @override
  String transitFormatTextReplenisherReplenishment(
      String index, String name, String details) {
    return 'Replenishment method at $index is called $name, $details.';
  }

  @override
  String transitFormatTextReplenisherReplenishmentDetails(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'it will adjust the inventory of $count ingredients',
      zero: 'it will not adjust inventory',
    );
    return '$_temp0';
  }

  @override
  String transitFormatTextOaHeader(int count) {
    return '$count customer attributes have been set.';
  }

  @override
  String get transitFormatTextOaHeaderSuffix =>
      'customer attributes have been set.';

  @override
  String transitFormatTextOaOa(
      String index, String name, String mode, String details) {
    return 'Attribute at $index is called $name, belongs to $mode type, $details.';
  }

  @override
  String transitFormatTextOaOaDetails(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'it has $count options',
      one: 'it has one option',
      zero: 'it has no options',
    );
    return '$_temp0';
  }

  @override
  String get transitFormatTextOaDefaultOption => 'default';

  @override
  String transitFormatTextOaModeValue(num value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return 'option value is $valueString';
  }

  @override
  String get transitGoogleSheetDialogTitle => 'Provide Google Sheets';

  @override
  String get transitGoogleSheetDialogCreate => 'Create New Spreadsheet';

  @override
  String get transitGoogleSheetDialogSelectExist =>
      'Select Existing Spreadsheet';

  @override
  String get transitGoogleSheetDialogConfirm => 'Confirm';

  @override
  String get transitGoogleSheetDialogIdLabel => 'Spreadsheet ID or URL';

  @override
  String get transitGoogleSheetDialogIdHelper =>
      'The ID is the combination of letters, numbers, underscores, and hyphens in the URL.\nFor example, the ID of \"https://docs.google.com/spreadsheets/d/1a2b3c4d5e6f7g8h9i0j\" is \"1a2b3c4d5e6f7g8h9i0j\".\nUsing existing spreadsheets may overwrite the data in the selected sheet.';

  @override
  String get transitGoogleSheetProgressCreate => 'Creating new spreadsheet';

  @override
  String get transitGoogleSheetProgressFulfill =>
      'Filling spreadsheet with sheets';

  @override
  String get transitGoogleSheetErrorCreateTitle =>
      'Unable to Create Spreadsheet';

  @override
  String get transitGoogleSheetErrorCreateHelper =>
      'Don\'t worry, it\'s usually easy to solve!\nPossible reasons include:\n• Unstable network conditions;\n• POS system not authorized to edit spreadsheets.';

  @override
  String get transitGoogleSheetErrorFulfillTitle =>
      'Unable to Create Sheet in Spreadsheet';

  @override
  String get transitGoogleSheetErrorFulfillHelper =>
      'Don\'t worry, it\'s usually easy to solve!\nPossible reasons include:\n• Unstable network conditions;\n• POS system not authorized to edit spreadsheets;\n• Misspelled spreadsheet ID, try copying the entire URL and pasting it;\n• The spreadsheet has been deleted.';

  @override
  String get transitGoogleSheetErrorIdNotFound => 'Spreadsheet not found';

  @override
  String get transitGoogleSheetErrorIdNotFoundHelper =>
      'Don\'t worry, it\'s usually easy to solve!\nPossible reasons include:\n• Unstable network conditions;\n• POS system not authorized to read sheets;\n• Misspelled spreadsheet ID, try copying the entire URL and pasting it;\n• The spreadsheet has been deleted.';

  @override
  String get transitGoogleSheetErrorIdEmpty => 'ID cannot be empty';

  @override
  String get transitGoogleSheetErrorIdInvalid =>
      'Invalid ID. It must include:\n• /spreadsheets/d/<ID>/\n• Or provide the ID directly (combination of letters, numbers, underscores, and hyphens).';

  @override
  String get appTitle => 'POS System';

  @override
  String get actSuccess => 'Successful!';

  @override
  String get actError => 'Error';

  @override
  String get actMoreInfo => 'More';

  @override
  String get singleChoice => 'Select One';

  @override
  String get multiChoices => 'Select Multiple';

  @override
  String totalCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString items',
      one: '$countString item',
      zero: 'No Items',
    );
    return '$_temp0';
  }

  @override
  String searchCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return 'Found $countString results';
  }

  @override
  String title(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'analysis': 'Stats',
        'stock': 'Inventory',
        'cashier': 'Cashier',
        'settings': 'Settings',
        'menu': 'Menu',
        'printers': 'Printer',
        'transit': 'Data Transfer',
        'orderAttributes': 'Customer Settings',
        'stockQuantities': 'Quantities',
        'elf': 'Suggestions',
        'more': 'More',
        'debug': 'Debug',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get dialogDeletionTitle => 'Delete Confirmation';

  @override
  String dialogDeletionContent(String name, String more) {
    return 'Are you sure you want to delete \"$name\"?\n\n${more}This action cannot be undone!\n';
  }

  @override
  String get imageHolderCreate => 'Tap to add image';

  @override
  String get imageHolderUpdate => 'Click to update image';

  @override
  String get imageBtnCrop => 'Crop';

  @override
  String get imageGalleryTitle => 'Gallery';

  @override
  String get imageGalleryEmpty => 'Start importing your first image!';

  @override
  String get imageGalleryActionCreate => 'Add Image';

  @override
  String get imageGalleryActionDelete => 'Delete';

  @override
  String get imageGallerySnackbarDeleteFailed =>
      'One or more images failed to delete.';

  @override
  String get imageGallerySelectionTitle => 'Select Images';

  @override
  String imageGallerySelectionDeleteConfirm(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return 'Will delete $countString image(s) permanently.\nAfter deletion, the connected product will not able to display the image.';
  }

  @override
  String get emptyBodyTitle => 'Oops! It\'s empty here.';

  @override
  String get emptyBodyAction => 'SETUP';

  @override
  String get btnNavTo => 'View';

  @override
  String get btnSignInWithGoogle => 'Sign in with Google';

  @override
  String semanticsPercentileBar(num percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.percentPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return 'Currently $percentString of total';
  }

  @override
  String invalidIntegerType(String field) {
    return '$field must be an integer.';
  }

  @override
  String invalidNumberType(String field) {
    return '$field must be a number.';
  }

  @override
  String invalidNumberPositive(String field) {
    return '$field cannot be negative.';
  }

  @override
  String invalidNumberMaximum(String field, num maximum) {
    final intl.NumberFormat maximumNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String maximumString = maximumNumberFormat.format(maximum);

    return '$field cannot exceed $maximumString.';
  }

  @override
  String invalidNumberMinimum(String field, num minimum) {
    final intl.NumberFormat minimumNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minimumString = minimumNumberFormat.format(minimum);

    return '$field cannot be less than $minimumString.';
  }

  @override
  String invalidStringEmpty(String field) {
    return '$field cannot be empty.';
  }

  @override
  String invalidStringMaximum(String field, int maximum) {
    return '$field cannot exceed $maximum characters.';
  }

  @override
  String get singleMonth => 'Single Month';

  @override
  String get singleWeek => 'Single Week';

  @override
  String get twoWeeks => 'Two Weeks';

  @override
  String get orderAttributeTitle => 'Customer Settings';

  @override
  String get orderAttributeDescription =>
      'Information for analysis such as dine-in, takeout, etc.';

  @override
  String get orderAttributeTitleCreate => 'Add Customer Setting';

  @override
  String get orderAttributeTitleUpdate => 'Edit Customer Setting';

  @override
  String get orderAttributeTitleReorder => 'Reorder Customer Settings';

  @override
  String get orderAttributeEmptyBody =>
      'Customer settings help us track who comes to consume, such as:\n20-30 years old, takeout, office workers, etc.';

  @override
  String get orderAttributeHeaderInfo => 'Customer Settings';

  @override
  String get orderAttributeTutorialTitle => 'Create Your Customer Settings';

  @override
  String get orderAttributeTutorialContent =>
      'This is where you set customer information, such as dine-in, takeout, office worker, etc.\nThis information helps us track who comes to consume and make better business strategies.';

  @override
  String get orderAttributeTutorialCreateExample =>
      'Help create an example to test.';

  @override
  String get orderAttributeExampleAge => 'Age';

  @override
  String get orderAttributeExampleAgeChild => 'Child';

  @override
  String get orderAttributeExampleAgeAdult => 'Adult';

  @override
  String get orderAttributeExampleAgeSenior => 'Senior';

  @override
  String get orderAttributeExamplePlace => 'Place';

  @override
  String get orderAttributeExamplePlaceTakeout => 'Takeout';

  @override
  String get orderAttributeExamplePlaceDineIn => 'Dine-in';

  @override
  String get orderAttributeExampleEcoFriendly => 'Eco-Friendly';

  @override
  String get orderAttributeExampleEcoFriendlyReusableBottle =>
      'Reusable Bottle';

  @override
  String get orderAttributeExampleEcoFriendlyReusableBag => 'Reusable Bag';

  @override
  String orderAttributeMetaMode(String name) {
    return 'Mode: $name';
  }

  @override
  String orderAttributeMetaDefault(String name) {
    return 'Default: $name';
  }

  @override
  String get orderAttributeMetaNoDefault => 'None';

  @override
  String get orderAttributeModeDivider => 'Customer Setting Mode';

  @override
  String orderAttributeModeName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'statOnly': 'Normal',
        'changePrice': 'Price Change',
        'changeDiscount': 'Discount',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String orderAttributeModeHelper(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'statOnly': 'Normal setting, selecting won\'t affect the order price.',
        'changePrice':
            'Selecting this setting may affect the order price.\nFor example: Takeout +\$30, Eco Cup -\$5.',
        'changeDiscount':
            'Selecting this setting will affect the total price based on the discount.\nFor example: Dine-in +10% service charge, Friends & Family Discount -10%.',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get orderAttributeNameLabel => 'Customer Setting Name';

  @override
  String get orderAttributeNameHint => 'e.g., Age';

  @override
  String get orderAttributeNameErrorRepeat => 'Name already exists';

  @override
  String get orderAttributeOptionTitleCreate => 'Add Option';

  @override
  String get orderAttributeOptionTitleUpdate => 'Edit Option';

  @override
  String get orderAttributeOptionTitleReorder => 'Reorder Options';

  @override
  String get orderAttributeOptionMetaDefault => 'Default';

  @override
  String orderAttributeOptionMetaOptionOf(String name) {
    return 'option of $name';
  }

  @override
  String get orderAttributeOptionNameLabel => 'Option Name';

  @override
  String get orderAttributeOptionNameHelper =>
      'For \'age\', possible options are:\n- ⇣ 20\n- 20 ⇢ 30';

  @override
  String get orderAttributeOptionNameErrorRepeat => 'Name already exists';

  @override
  String get orderAttributeOptionModeTitle => 'Option Mode';

  @override
  String orderAttributeOptionModeHelper(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'statOnly':
            'No need to set \"Discount\" or \"Price Change\" because this setting is \"Normal\"',
        'changePrice':
            'Selecting this option during ordering will apply this price change',
        'changeDiscount':
            'Selecting this option during ordering will apply this discount',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String orderAttributeOptionModeHint(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'statOnly': '',
        'changePrice': 'For example: -30 means decrease by thirty dollars',
        'changeDiscount': 'For example: 80 means \"20% off\"',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get orderAttributeOptionToDefaultLabel => 'Set as Default';

  @override
  String get orderAttributeOptionToDefaultHelper =>
      'Set this option as the default value, which will be used for each order by default.';

  @override
  String get orderAttributeOptionToDefaultConfirmChangeTitle =>
      'Override Option Default?';

  @override
  String orderAttributeOptionToDefaultConfirmChangeContent(String name) {
    return 'Doing this will make \"$name\" no longer the default value';
  }

  @override
  String get orderAttributeValueEmpty => 'No price impact';

  @override
  String get orderAttributeValueFree => 'Free';

  @override
  String get menuTitle => 'Menu';

  @override
  String get menuSubtitle => 'Categories, Products';

  @override
  String get menuTutorialTitle => 'Create Your Menu';

  @override
  String get menuTutorialContent => 'Let\'s start by creating a menu!';

  @override
  String get menuTutorialCreateExample =>
      'Help create an example menu to test.';

  @override
  String get menuSearchHint => 'Search for products, ingredients, quantities';

  @override
  String get menuSearchNotFound =>
      'Couldn\'t find relevant information. Did you misspell something?';

  @override
  String get menuExampleCatalogBurger => 'Burgers';

  @override
  String get menuExampleCatalogDrink => 'Drinks';

  @override
  String get menuExampleCatalogSide => 'Side';

  @override
  String get menuExampleCatalogOther => 'Others';

  @override
  String get menuExampleProductCheeseBurger => 'Cheese Burger';

  @override
  String get menuExampleProductVeggieBurger => 'Veggie Burger';

  @override
  String get menuExampleProductHamBurger => 'Ham Burger';

  @override
  String get menuExampleProductCola => 'Cola';

  @override
  String get menuExampleProductCoffee => 'Coffee';

  @override
  String get menuExampleProductFries => 'Fries';

  @override
  String get menuExampleProductStraw => 'Straw';

  @override
  String get menuExampleProductPlasticBag => 'Plastic Bag';

  @override
  String get menuExampleIngredientCheese => 'Cheese';

  @override
  String get menuExampleIngredientLettuce => 'Lettuce';

  @override
  String get menuExampleIngredientTomato => 'Tomato';

  @override
  String get menuExampleIngredientBun => 'Bun';

  @override
  String get menuExampleIngredientChili => 'Chili Sauce';

  @override
  String get menuExampleIngredientHam => 'Ham';

  @override
  String get menuExampleIngredientCola => 'Can of Cola';

  @override
  String get menuExampleIngredientCoffee => 'Drip Coffee';

  @override
  String get menuExampleIngredientFries => 'Bag of Fries';

  @override
  String get menuExampleIngredientStraw => 'Straw';

  @override
  String get menuExampleIngredientPlasticBag => 'Plastic Bag';

  @override
  String get menuExampleQuantitySmall => 'Small';

  @override
  String get menuExampleQuantityLarge => 'Large';

  @override
  String get menuExampleQuantityNone => 'None';

  @override
  String get menuCatalogEmptyBody =>
      'Similar products will be grouped under categories,\nmaking ordering convenient, such as:\n• \"Cheese Burger\", \"Veggie Burger\" > \"Burgers\"\n• \"Plastic Bag\", \"Eco Cup\" > \"Others\"';

  @override
  String get menuCatalogTitleCreate => 'Add Category';

  @override
  String get menuCatalogTitleUpdate => 'Edit Category';

  @override
  String get menuCatalogTitleReorder => 'Reorder Categories';

  @override
  String menuCatalogDialogDeletionContent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Will also delete $count related products',
      one: 'Will also delete $count related product',
      zero: 'No products inside',
    );
    return '$_temp0';
  }

  @override
  String get menuCatalogNameLabel => 'Category Name';

  @override
  String get menuCatalogNameHint => 'e.g., Burgers';

  @override
  String get menuCatalogNameErrorRepeat =>
      'Name already exists. Please choose a different name!';

  @override
  String get menuCatalogEmptyProducts => 'No products set yet';

  @override
  String get menuProductHeaderInfo => 'Products';

  @override
  String get menuProductEmptyBody =>
      '\"Products\" are the basic units in the menu, such as:\n\"Cheese Burger\", \"Cola\"';

  @override
  String get menuProductNotSelected => 'Please select a category first';

  @override
  String get menuProductTitleCreate => 'Add Product';

  @override
  String get menuProductTitleUpdate => 'Edit Product';

  @override
  String get menuProductTitleReorder => 'Reorder Products';

  @override
  String get menuProductTitleUpdateImage => 'Update Photo';

  @override
  String get menuProductMetaTitle => 'Product';

  @override
  String menuProductMetaPrice(num price) {
    final intl.NumberFormat priceNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String priceString = priceNumberFormat.format(price);

    return 'Price: $priceString';
  }

  @override
  String menuProductMetaCost(num cost) {
    final intl.NumberFormat costNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String costString = costNumberFormat.format(cost);

    return 'Cost: $costString';
  }

  @override
  String get menuProductMetaEmpty => 'No ingredients set';

  @override
  String get menuProductNameLabel => 'Product Name';

  @override
  String get menuProductNameHint => 'e.g., Cheeseburger';

  @override
  String get menuProductNameErrorRepeat => 'Product name already exists';

  @override
  String get menuProductPriceLabel => 'Product Price';

  @override
  String get menuProductPriceHelper => 'Price displayed on the order page';

  @override
  String get menuProductCostLabel => 'Product Cost';

  @override
  String get menuProductCostHelper =>
      'Used to calculate profit, should be less than the price';

  @override
  String get menuProductEmptyIngredients => 'No ingredients set yet';

  @override
  String get menuIngredientEmptyBody =>
      'You can set ingredients for the product, such as:\n\"Cheeseburger\" with \"Cheese\", \"Bun\" as ingredients';

  @override
  String get menuIngredientTitleCreate => 'Add Ingredient';

  @override
  String get menuIngredientTitleUpdate => 'Edit Ingredient';

  @override
  String get menuIngredientTitleReorder => 'Reorder Ingredients';

  @override
  String menuIngredientMetaAmount(num amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return 'Amount: $amountString';
  }

  @override
  String get menuIngredientSearchLabel => 'Search Ingredients';

  @override
  String get menuIngredientSearchHelper =>
      'After adding ingredient, you can set related information in \"Inventory\".';

  @override
  String get menuIngredientSearchHint => 'e.g., Cheese';

  @override
  String menuIngredientSearchAdd(String name) {
    return 'Add Ingredient \"$name\"';
  }

  @override
  String get menuIngredientSearchErrorEmpty =>
      'Ingredient must be set, please click to set.';

  @override
  String get menuIngredientSearchErrorRepeat =>
      'Product already has the same ingredient, cannot select repeatedly.';

  @override
  String get menuIngredientAmountLabel => 'Amount Used';

  @override
  String get menuIngredientAmountHelper =>
      'Default amount used.\nIf customers are able to adjust the amount,\nset different quantities in \"Quantity.\"';

  @override
  String get menuQuantityTitleCreate => 'Add Quantity';

  @override
  String get menuQuantityTitleUpdate => 'Edit';

  @override
  String menuQuantityMetaAmount(num amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return 'Amount: $amountString';
  }

  @override
  String menuQuantityMetaAdditionalPrice(String price) {
    return 'Price: $price';
  }

  @override
  String menuQuantityMetaAdditionalCost(String cost) {
    return 'Cost: $cost';
  }

  @override
  String get menuQuantitySearchLabel => 'Search Quantity';

  @override
  String get menuQuantitySearchHelper =>
      'After adding ingredient quantity, you can set related information in \"Quantity\".';

  @override
  String get menuQuantitySearchHint => 'e.g., Large, Small';

  @override
  String menuQuantitySearchAdd(String name) {
    return 'Add Quantity \"$name\"';
  }

  @override
  String get menuQuantitySearchErrorEmpty =>
      'Quantity must be set, please click to set.';

  @override
  String get menuQuantitySearchErrorRepeat =>
      'Product already has the same quantity, cannot select repeatedly.';

  @override
  String get menuQuantityAmountLabel => 'Amount Used';

  @override
  String get menuQuantityAdditionalPriceLabel => 'Additional Price';

  @override
  String get menuQuantityAdditionalPriceHelper =>
      'Set to 0 to indicate no additional charge for extra (or less) quantity.';

  @override
  String get menuQuantityAdditionalCostLabel => 'Additional Cost';

  @override
  String get menuQuantityAdditionalCostHelper =>
      'Additional cost can be negative, e.g., \"Less\" reduces ingredient usage, reducing cost accordingly.';

  @override
  String get cashierTab => 'Cashier';

  @override
  String cashierUnitLabel(String unit) {
    return '\$$unit';
  }

  @override
  String get cashierCounterLabel => 'Quantity';

  @override
  String get cashierToDefaultTitle => 'Set as Default';

  @override
  String get cashierToDefaultTutorialTitle => 'Cash Register Default Status';

  @override
  String get cashierToDefaultTutorialContent =>
      'After setting the quantities of various currencies below,\nclick here to set the default status!\nThe set quantities will be the \"maximum\" for each currency status bar.';

  @override
  String get cashierToDefaultDialogTitle => 'Adjust Cash Register Default?';

  @override
  String get cashierToDefaultDialogContent =>
      'This will set the current cash register status as the default status.\nThis action will override previous settings.';

  @override
  String get cashierChangerTitle => 'Changer';

  @override
  String get cashierChangerButton => 'Apply';

  @override
  String get cashierChangerTutorialTitle => 'Cash Register Money Changer';

  @override
  String get cashierChangerTutorialContent =>
      'Exchange one hundred for 10 tens, for example.\nHelps to quickly adjust the cash register status.';

  @override
  String get cashierChangerErrorNoSelection =>
      'Please select a combination to apply';

  @override
  String cashierChangerErrorNotEnough(String unit) {
    return 'Not enough \$$unit';
  }

  @override
  String cashierChangerErrorInvalidHead(int count, String unit) {
    return 'Cannot exchange $count of \$$unit to';
  }

  @override
  String cashierChangerErrorInvalidBody(int count, String unit) {
    return '$count of \$$unit';
  }

  @override
  String get cashierChangerFavoriteTab => 'Favorites';

  @override
  String get cashierChangerFavoriteHint =>
      'After selecting, please click \"Apply\" to use the combination.';

  @override
  String get cashierChangerFavoriteEmptyBody =>
      'Here can help you quickly convert different currencies.';

  @override
  String cashierChangerFavoriteItemFrom(int count, String unit) {
    return 'Exchange $count of \$$unit to';
  }

  @override
  String cashierChangerFavoriteItemTo(int count, String unit) {
    return '$count of \$$unit';
  }

  @override
  String get cashierChangerCustomTab => 'Custom';

  @override
  String get cashierChangerCustomAddBtn => 'Add Favorite';

  @override
  String get cashierChangerCustomCountLabel => 'Quantity';

  @override
  String get cashierChangerCustomUnitLabel => 'Currency';

  @override
  String get cashierChangerCustomUnitAddBtn => 'Add Currency';

  @override
  String get cashierChangerCustomDividerFrom => 'Take';

  @override
  String get cashierChangerCustomDividerTo => 'Exchange to';

  @override
  String get cashierSurplusTitle => 'Surplus';

  @override
  String get cashierSurplusButton => 'Surplus';

  @override
  String get cashierSurplusTutorialTitle => 'Daily Surplus';

  @override
  String get cashierSurplusTutorialContent =>
      'Surplus helps us at the end of each day,\ncalculate the difference between the current amount and the default amount.';

  @override
  String get cashierSurplusErrorEmptyDefault => 'Default status not set yet';

  @override
  String get cashierSurplusTableHint =>
      'Once you confirm that there are no issues with the cash register money, you can complete the surplus!';

  @override
  String cashierSurplusColumnName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'unit': 'Unit',
        'currentCount': 'Current',
        'diffCount': 'Difference',
        'defaultCount': 'Default',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String cashierSurplusCounterLabel(String unit) {
    return 'Quantity of \$$unit';
  }

  @override
  String get cashierSurplusCounterShortLabel => 'Quantity';

  @override
  String get cashierSurplusCurrentTotalLabel => 'Current Total';

  @override
  String get cashierSurplusCurrentTotalHelper =>
      'The total amount the cash register should have now.\nIf you find that the cash and this value don\'t match, think about whether you used the cash register to buy something today?';

  @override
  String get cashierSurplusDiffTotalLabel => 'Difference';

  @override
  String get cashierSurplusDiffTotalHelper =>
      'The difference from the total amount of the cash register at the very beginning.\nThis can quickly help you understand how much money the cash register has gained today.';

  @override
  String get orderTitle => 'Ordering';

  @override
  String get orderBtn => 'Order';

  @override
  String get orderTutorialTitle => 'Ordering!';

  @override
  String get orderTutorialContent =>
      'Once you have set up your menu, you can start ordering!\nLet\'s tap and go see what\'s available!\n';

  @override
  String get orderTutorialPrinterBtnTitle => 'Printer Status Change';

  @override
  String get orderTutorialPrinterBtnContent =>
      'Printer status has changed, please check.';

  @override
  String orderSnackbarPrinterConnected(String names) {
    return 'Printer connected: $names';
  }

  @override
  String orderSnackbarPrinterDisconnected(String name) {
    return 'Printer \"$name\" disconnected';
  }

  @override
  String get orderSnackbarCashierNotEnough =>
      'Insufficient cash in the cashier!';

  @override
  String get orderSnackbarCashierUsingSmallMoney =>
      'Using smaller denominations to give change';

  @override
  String orderSnackbarCashierUsingSmallMoneyHelper(String link) {
    return 'When giving change to customers, if the cashier doesn\'t have the appropriate denominations, this message will appear.\n\nFor example, if the total is \$65 and the customer pays \$100, the change should be \$35.\nIf the cashier only has two \$10 bills and more than three \$5 bills, this message will appear.\n\nTo avoid this prompt:\n• Go to the changer page and top up various denominations.\n• Go to the [settings page]($link) to disable related prompts from the cashier.';
  }

  @override
  String get orderActionCheckout => 'Checkout';

  @override
  String get orderActionExchange => 'Exchange';

  @override
  String get orderActionStash => 'Stash';

  @override
  String get orderActionReview => 'Order History';

  @override
  String orderLoaderMetaTotalRevenue(String revenue) {
    return 'Revenue: $revenue';
  }

  @override
  String orderLoaderMetaTotalCost(String cost) {
    return 'Cost: $cost';
  }

  @override
  String orderLoaderMetaTotalCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return 'Count: $countString';
  }

  @override
  String get orderLoaderEmpty => 'No order records found';

  @override
  String get orderCatalogListEmpty => 'No product categories set yet';

  @override
  String orderProductListViewHelper(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'grid': 'Grid',
        'list': 'List',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get orderProductListNoIngredient => 'No ingredients';

  @override
  String get orderPrinterEmpty => 'No printers set yet';

  @override
  String get orderPrinterDividerUnused => 'Unused';

  @override
  String get orderPrinterDividerConnecting => 'Connecting';

  @override
  String get orderPrinterDividerConnected => 'Connected';

  @override
  String get orderPrinterErrorCreateReceipt => 'Unable to generate receipt';

  @override
  String get orderCartActionBulk => 'Bulk Actions';

  @override
  String get orderCartActionToggle => 'Toggle';

  @override
  String get orderCartActionSelectAll => 'Select All';

  @override
  String get orderCartActionDiscount => 'Discount';

  @override
  String get orderCartActionDiscountLabel => 'Discount';

  @override
  String get orderCartActionDiscountHint => 'e.g., 30 means 70% off';

  @override
  String get orderCartActionDiscountHelper =>
      'The number here represents the \"percentage\" off, i.e., 85 means 15% off. For precise prices, use \"Price Change\".';

  @override
  String get orderCartActionDiscountSuffix => '%';

  @override
  String get orderCartActionChangePrice => 'Change Price';

  @override
  String get orderCartActionChangePriceLabel => 'Price';

  @override
  String get orderCartActionChangePriceHint => 'Price per item';

  @override
  String get orderCartActionChangePricePrefix => '\$';

  @override
  String get orderCartActionChangePriceSuffix => '';

  @override
  String get orderCartActionChangeCount => 'Change Quantity';

  @override
  String get orderCartActionChangeCountLabel => 'Quantity';

  @override
  String get orderCartActionChangeCountHint => 'Quantity of items';

  @override
  String get orderCartActionChangeCountSuffix => 'items';

  @override
  String get orderCartActionFree => 'Free';

  @override
  String get orderCartActionDelete => 'Delete';

  @override
  String get orderCartSnapshotEmpty => 'No items in cart';

  @override
  String orderCartMetaTotalPrice(String price) {
    return 'Price: $price';
  }

  @override
  String orderCartMetaTotalCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return 'Count: $countString';
  }

  @override
  String orderCartProductPrice(String price) {
    String _temp0 = intl.Intl.selectLogic(
      price,
      {
        '0': 'Free',
        'other': '\$$price',
      },
    );
    return '$_temp0';
  }

  @override
  String get orderCartProductIncrease => 'Increase Quantity';

  @override
  String get orderCartProductDefaultQuantity => 'Default Quantity';

  @override
  String orderCartProductIngredient(String name, String quantity) {
    return '$name ($quantity)';
  }

  @override
  String orderCartIngredientStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(
      status,
      {
        'emptyCart': 'Please select a product to set its ingredients',
        'differentProducts':
            'Please select the same product to set its ingredients',
        'noNeedIngredient': 'This product doesn\'t require ingredient settings',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get orderCartQuantityNotAble =>
      'Please select an ingredient to set quantity';

  @override
  String orderCartQuantityLabel(String name, num amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '$name ($amountString)';
  }

  @override
  String orderCartQuantityDefaultLabel(num amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return 'Default ($amountString)';
  }

  @override
  String get orderCheckoutEmptyCart => 'Please make an order first.';

  @override
  String get orderCheckoutActionStash => 'Stash';

  @override
  String get orderCheckoutActionConfirm => 'Confirm';

  @override
  String get orderCheckoutStashTab => 'Stash';

  @override
  String get orderCheckoutStashEmpty => 'No items currently stashed.';

  @override
  String get orderCheckoutStashNoProducts => 'No products';

  @override
  String get orderCheckoutStashActionCheckout => 'Checkout';

  @override
  String get orderCheckoutStashActionRestore => 'Restore';

  @override
  String get orderCheckoutStashDialogCalculator => 'Checkout Calculator';

  @override
  String get orderCheckoutStashDialogRestoreTitle => 'Restore Stashed Order';

  @override
  String get orderCheckoutStashDialogRestoreContent =>
      'This action will override the current cart contents.';

  @override
  String get orderCheckoutStashDialogDeleteName => 'order';

  @override
  String get orderCheckoutAttributeTab => 'Customer';

  @override
  String get orderCheckoutAttributeNoteTitle => '備註';

  @override
  String get orderCheckoutAttributeNoteHint => '一些關於此訂單的說明';

  @override
  String get orderCheckoutDetailsTab => 'Details';

  @override
  String get orderCheckoutDetailsCalculatorLabelPaid => 'Paid';

  @override
  String get orderCheckoutDetailsCalculatorLabelChange => 'Change';

  @override
  String orderCheckoutDetailsSnapshotLabelChange(String change) {
    return 'Change: $change';
  }

  @override
  String get orderCheckoutSnackbarPaidFailed =>
      'Payment is less than the order amount.';

  @override
  String get orderObjectViewEmpty => 'No order records found';

  @override
  String get orderObjectViewChange => 'Change';

  @override
  String orderObjectViewPriceTotal(String price) {
    return 'Total Price: $price';
  }

  @override
  String get orderObjectViewPriceProducts => 'Product Price';

  @override
  String get orderObjectViewPriceAttributes => 'Customer Settings Price';

  @override
  String get orderObjectViewCost => 'Cost';

  @override
  String get orderObjectViewProfit => 'Profit';

  @override
  String get orderObjectViewPaid => 'Paid';

  @override
  String get orderObjectViewNote => 'Note';

  @override
  String get orderObjectViewDividerAttribute => 'Customer Settings';

  @override
  String get orderObjectViewDividerProduct => 'Product Information';

  @override
  String get orderObjectViewProductPrice => 'Price';

  @override
  String get orderObjectViewProductCost => 'Cost';

  @override
  String get orderObjectViewProductCount => 'Count';

  @override
  String get orderObjectViewProductSinglePrice => 'Unit Price';

  @override
  String get orderObjectViewProductOriginalPrice => 'Original Unit Price';

  @override
  String get orderObjectViewProductCatalog => 'Product Category';

  @override
  String get orderObjectViewProductIngredient => 'Ingredients';

  @override
  String get orderObjectViewProductDefaultQuantity => 'Default';

  @override
  String get analysisTab => 'Stats';

  @override
  String get analysisHistoryBtn => 'Records';

  @override
  String get analysisHistoryTitle => 'Order Records';

  @override
  String get analysisHistoryTitleEmpty => 'No Order History Found';

  @override
  String get analysisHistoryCalendarTutorialTitle => 'Calendar';

  @override
  String get analysisHistoryCalendarTutorialContent =>
      'Swipe up and down to adjust the time period, such as month or week.\nSwipe left and right to adjust the date range.';

  @override
  String get analysisHistoryExportBtn => 'Export';

  @override
  String get analysisHistoryExportTutorialTitle => 'Export Orders Data';

  @override
  String get analysisHistoryExportTutorialContent =>
      'Export orders externally for further analysis or backup.\nYou can export multi-day orders in the \"Transit\" page.';

  @override
  String analysisHistoryOrderListMetaId(String id) {
    return 'ID: $id';
  }

  @override
  String analysisHistoryOrderListMetaPrice(num price) {
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.compactCurrency(locale: localeName, symbol: '\$');
    final String priceString = priceNumberFormat.format(price);

    return 'Price: $priceString';
  }

  @override
  String analysisHistoryOrderListMetaPaid(num paid) {
    final intl.NumberFormat paidNumberFormat =
        intl.NumberFormat.compactCurrency(locale: localeName, symbol: '\$');
    final String paidString = paidNumberFormat.format(paid);

    return 'Paid: $paidString';
  }

  @override
  String analysisHistoryOrderListMetaProfit(num profit) {
    final intl.NumberFormat profitNumberFormat =
        intl.NumberFormat.compactCurrency(locale: localeName, symbol: '\$');
    final String profitString = profitNumberFormat.format(profit);

    return 'Profit: $profitString';
  }

  @override
  String analysisHistoryOrderTitle(String id) {
    return 'ID: $id';
  }

  @override
  String get analysisHistoryOrderNotFound => 'No relevant orders found';

  @override
  String analysisHistoryOrderDeleteDialog(String name) {
    return 'Are you sure you want to delete the order for $name?\nCash register and inventory data cannot be recovered.\nThis action cannot be undone.';
  }

  @override
  String get analysisGoalsTitle => 'Today\'s Summary';

  @override
  String get analysisGoalsCountTitle => 'Order Count';

  @override
  String get analysisGoalsCountDescription =>
      'The order count reflects the attractiveness of products to customers.\nIt represents the demand for your products in the market and helps you understand which products or time periods are most popular.\nA high order count may indicate the success of your pricing strategy or marketing activities and is one of the indicators of business model effectiveness.\nHowever, it\'s essential to note that simply pursuing a high order count may overlook profitability.';

  @override
  String get analysisGoalsRevenueTitle => 'Revenue';

  @override
  String get analysisGoalsRevenueDescription =>
      'Revenue represents the total sales amount and is an indicator of business scale.\nHigh revenue may indicate that your products are popular and selling well, but revenue alone cannot reflect the sustainability and profitability of the business.\nSometimes, to increase revenue, companies may adopt strategies such as price reductions, which may affect profitability.';

  @override
  String get analysisGoalsProfitTitle => 'Profit';

  @override
  String get analysisGoalsProfitDescription =>
      'Profit is the balance after deducting operating costs from operating income and is crucial for the company\'s ongoing operations.\nProfit directly reflects operational efficiency and cost management capabilities.\nUnlike revenue, profit considers the business expenses, including raw material costs, labor, rent, etc.\nIt\'s a more practical indicator that helps you evaluate the effectiveness and sustainability of operations.';

  @override
  String get analysisGoalsCostTitle => 'Cost';

  @override
  String analysisGoalsAchievedRate(String rate) {
    return 'Profit Goal\n$rate';
  }

  @override
  String get analysisChartTitle => 'Chart Analysis';

  @override
  String get analysisChartTitleCreate => 'Create Chart';

  @override
  String get analysisChartTitleUpdate => 'Edit Chart';

  @override
  String get analysisChartTitleReorder => 'Reorder Charts';

  @override
  String get analysisChartTutorialTitle => 'Chart Analysis';

  @override
  String get analysisChartTutorialContent =>
      'With charts, you can visualize data changes more intuitively.\nStart designing charts to track your sales performance now!';

  @override
  String get analysisChartCardEmptyData => 'No Data';

  @override
  String get analysisChartCardTitleUpdate => 'Edit Chart';

  @override
  String analysisChartMetricName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'revenue': 'Revenue',
        'cost': 'Cost',
        'profit': 'Profit',
        'count': 'Quantity',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String analysisChartTargetName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'order': 'Order',
        'catalog': 'Category',
        'product': 'Product',
        'ingredient': 'Ingredient',
        'attribute': 'Attribute',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get analysisChartRangeYesterday => 'Yesterday';

  @override
  String get analysisChartRangeToday => 'Today';

  @override
  String get analysisChartRangeLastWeek => 'Last Week';

  @override
  String get analysisChartRangeThisWeek => 'This Week';

  @override
  String get analysisChartRangeLast7Days => 'Last 7 Days';

  @override
  String get analysisChartRangeLastMonth => 'Last Month';

  @override
  String get analysisChartRangeThisMonth => 'This Month';

  @override
  String get analysisChartRangeLast30Days => 'Last 30 Days';

  @override
  String analysisChartRangeTabName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'day': 'Date',
        'week': 'Week',
        'month': 'Month',
        'custom': 'Custom',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get analysisChartModalNameLabel => 'Chart Name';

  @override
  String get analysisChartModalNameHint => 'For example: Daily Revenue';

  @override
  String get analysisChartModalIgnoreEmptyLabel => 'Ignore Empty Data';

  @override
  String get analysisChartModalIgnoreEmptyHelper =>
      'Do not display if a product or metric has no data for that period.';

  @override
  String get analysisChartModalDivider => 'Data Settings';

  @override
  String get analysisChartModalTypeLabel => 'Chart Type';

  @override
  String analysisChartModalTypeName(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'cartesian': 'Time Series Chart',
        'circular': 'Pie Chart',
        'other': 'UNKNOWN',
      },
    );
    return '$_temp0';
  }

  @override
  String get analysisChartModalMetricLabel => 'Metrics to View';

  @override
  String get analysisChartModalMetricHelper =>
      'Choose different types of metrics based on your objectives.';

  @override
  String get analysisChartModalTargetLabel => 'Item Category';

  @override
  String get analysisChartModalTargetHelper =>
      'Select the information to analyze in the chart.';

  @override
  String get analysisChartModalTargetErrorEmpty =>
      'Please select an item category';

  @override
  String get analysisChartModalTargetItemLabel => 'Item Selection';

  @override
  String get analysisChartModalTargetItemHelper =>
      'Choose the items you want to observe, such as the quantity of a specific product within a certain period.';

  @override
  String get analysisChartModalTargetItemSelectAll => 'Select All';
}
