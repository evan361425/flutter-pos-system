import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  initializeDateFormatting('en', null);
  print(DateFormat('yMMdd').format(DateTime.now()));
}
