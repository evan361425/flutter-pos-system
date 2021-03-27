import 'package:uuid/uuid.dart';

class Util {
  static final uuid = Uuid();

  static String uuidV4() {
    return uuid.v4();
  }

  static int similarity(String str1, String str2) {
    // starts with [searchText]
    var score =
        str1.split(' ').where((element) => element.startsWith(str2)).length * 2;
    // contains
    score += str1.contains(str2) ? 1 : 0;

    return score;
  }
}
