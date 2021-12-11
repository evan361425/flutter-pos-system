import 'package:mockito/annotations.dart';
import 'package:possystem/services/image_dumper.dart';

import 'mock_image_dumper.mocks.dart';

final imagedumper = MockImageDumper();

@GenerateMocks([ImageDumper])
void initializeImageDumper() {
  ImageDumper.instance = imagedumper;
}
