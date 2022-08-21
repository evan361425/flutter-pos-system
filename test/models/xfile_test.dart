import 'package:file/local.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/xfile.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../test_helpers/file_mocker.dart';

void main() {
  group('XFile', () {
    testWidgets('#getRootPath', (tester) async {
      XFile.fs = const LocalFileSystem();

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        (PathProviderPlatform.instance as dynamic).methodChannel,
        (MethodCall methodCall) {
          expect(methodCall.method, 'getApplicationDocumentsDirectory');
          return Future.value('');
        },
      );

      await XFile.getRootPath();

      initializeFileSystem();
    });
  });
}
