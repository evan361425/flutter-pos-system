import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/image_file.dart';
import 'package:possystem/services/image_dumper.dart';

import 'mock_image_dumper.mocks.dart';

final imageDumper = MockImageDumper();

@GenerateMocks([ImageDumper, ImageFile])
void initializeImageDumper() {
  ImageDumper.instance = imageDumper;
}

void prepareItemImageSave(String folder) {
  final image = MockImageFile();
  final resizedImage = MockImageFile();

  when(image.path).thenReturn('picked-path');
  when(image.fileCopy(any)).thenAnswer((_) => Future.value(MockImageFile()));
  when(imageDumper.getPath(any)).thenAnswer((_) => Future.value(folder));

  when(imageDumper.pick()).thenAnswer((_) => Future.value(image));

  when(imageDumper.resize(any, width: anyNamed('width')))
      .thenAnswer((_) => Future.value(resizedImage));

  when(resizedImage.toPNG(any)).thenAnswer((_) => Future.value(
        const ImageFile(path: 'picked-resized'),
      ));
}
