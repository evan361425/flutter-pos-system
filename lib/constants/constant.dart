import 'package:flutter/foundation.dart';

const double kTopSpacing = 12.0;
const double kHorizontalSpacing = 10.0;
const double kInternalSpacing = 5.5;
const double kInternalLargeSpacing = 12.0;
const double kFABSpacing = 76.0;
const double kDialogBottomSpacing = 24.0;
const bool isLocalTest = String.fromEnvironment('appFlavor') == 'debug';
const bool isInternalTest = String.fromEnvironment('appFlavor') == 'dev';
const bool isProd = String.fromEnvironment('appFlavor') == 'prod';

/// The time to show the warning message when the bluetooth is not found.
const Duration btSearchWarningTime = kDebugMode ? Duration(milliseconds: 10) : Duration(minutes: 1);
