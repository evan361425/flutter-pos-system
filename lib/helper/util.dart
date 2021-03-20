import 'package:uuid/uuid.dart';

class Util {
  static final uuid = Uuid();

  static String uuidV4() {
    return uuid.v4();
  }
}
