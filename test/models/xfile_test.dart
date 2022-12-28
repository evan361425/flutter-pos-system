import 'package:file/local.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/xfile.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/src/method_channel_path_provider.dart';

import '../test_helpers/file_mocker.dart';

void main() {
  group('XFile', () {
    testWidgets('#getRootPath', (tester) async {
      XFile.fs = const LocalFileSystem();
      final provider = MethodChannelPathProvider();
      PathProviderPlatform.instance = provider;

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        provider.methodChannel,
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
