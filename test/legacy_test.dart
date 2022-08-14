import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/customer/customer_setting_option.dart';
import 'package:possystem/models/repository/customer_settings.dart';

import 'mocks/mock_database.dart';

void main() {
  group('Legacy', () {
    group('Customer Setting', () {
      test('save and add', () async {
        when(database.push(any, any)).thenAnswer((_) => Future.value(1));
        when(database.update(any, any, any)).thenAnswer((_) => Future.value(1));
        when(database.batchUpdate(
          any,
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        )).thenAnswer((_) => Future.value([]));
        final settings = CustomerSettings();
        final option = CustomerSettingOption(name: 'q', id: 'q');
        final setting =
            CustomerSetting(name: '1', index: 1, options: {'q': option});
        setting.prepareItem();

        await settings.addItem(setting);

        expect(setting.repository.length, 1);
        expect(option.repository.length, 1);
        expect(setting.id, '1');
        expect(setting.name, '1');

        await setting.save({'name': '2'});
        await settings.reorderItems([
          CustomerSetting(
            id: '2',
            name: '2',
            index: 1,
          ),
          setting
        ]);
      });

      test('initialize', () async {
        when(database.query(any, where: anyNamed('where'))).thenThrow('');

        await CustomerSettings().initialize();
      });

      test('remove', () async {
        when(database.update(any, any, any)).thenAnswer((_) => Future.value(1));
        final settings = CustomerSettings();
        final option = CustomerSettingOption(id: '1', name: 'o');
        final setting =
            CustomerSetting(id: '2', name: 'a', options: {'o': option});
        settings.replaceItems({'a': setting});
        setting.prepareItem();

        await option.remove();

        await settings.dropItems();
      });

      setUp(() {
        initializeDatabase();
      });
    });
  });
}
