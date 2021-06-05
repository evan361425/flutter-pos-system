import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/helper/logger.dart';

void main() {
  setUpAll(() {
    // disable logger
    LEVEL = 0;
  });
}
