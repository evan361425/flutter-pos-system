import 'package:file/memory.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/xfile.dart';

void initializeFileSystem() {
  XFile.fs = MemoryFileSystem();
}

void mockImagePick(WidgetTester tester, [bool canceled = false]) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/image_picker'),
    (MethodCall methodCall) async {
      if (canceled) return null;

      final tempDir = XFile.fs.systemTempDirectory.path;
      final file = XFile('$tempDir/picked-image');
      await file.file.writeAsBytes(_examplePng);

      return file.path;
    },
  );
}

void mockImageCropper(WidgetTester tester, [bool canceled = false]) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.hunghd.vn/image_cropper'),
    (MethodCall methodCall) async {
      if (canceled) return null;

      final tempDir = XFile.fs.systemTempDirectory.path;
      final file = XFile('$tempDir/cropped-image');
      await file.file.writeAsBytes(_examplePng);

      return file.path;
    },
  );
}

Future<String> createImage(String path) async {
  final tempDir = XFile.fs.systemTempDirectory.path;
  final file = XFile('$tempDir/$path');
  await file.file.writeAsBytes(_examplePng);

  return file.path;
}

const _examplePng = <int>[
  137,
  80,
  78,
  71,
  13,
  10,
  26,
  10,
  0,
  0,
  0,
  13,
  73,
  72,
  68,
  82,
  0,
  0,
  1,
  0,
  0,
  0,
  1,
  0,
  1,
  3,
  0,
  0,
  0,
  102,
  188,
  58,
  37,
  0,
  0,
  0,
  3,
  80,
  76,
  84,
  69,
  181,
  208,
  208,
  99,
  4,
  22,
  234,
  0,
  0,
  0,
  31,
  73,
  68,
  65,
  84,
  104,
  129,
  237,
  193,
  1,
  13,
  0,
  0,
  0,
  194,
  160,
  247,
  79,
  109,
  14,
  55,
  160,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  190,
  13,
  33,
  0,
  0,
  1,
  154,
  96,
  225,
  213,
  0,
  0,
  0,
  0,
  73,
  69,
  78,
  68,
  174,
  66,
  96,
  130
];
