import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/models/xfile.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/image_gallery_page.dart';

import 'test_helpers/breakpoint_mocker.dart';
import 'test_helpers/file_mocker.dart';
import 'test_helpers/translator.dart';

void main() {
  Widget createApp(void Function(String?) cb) {
    return MaterialApp.router(
      routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
        GoRoute(
          path: '/',
          builder: (ctx, state) {
            return Scaffold(body: Builder(builder: (context) {
              return TextButton(
                onPressed: () async {
                  final result = await context.pushNamed(Routes.imageGallery);
                  cb(result as String?);
                },
                child: const Text('go'),
              );
            }));
          },
        ),
        ...Routes.getDesiredRoute(0).routes,
      ]),
    );
  }

  group('Image Gallery Page', () {
    Future<String> createImageAt(String name) async {
      return createImage(name, parent: 'menu_image');
    }

    for (final device in [Device.desktop, Device.mobile]) {
      group(device.name, () {
        testWidgets('create', (tester) async {
          deviceAs(device, tester);
          String? imagePath;
          await tester.pumpWidget(createApp((v) => imagePath = v));

          await tester.tap(find.text('go'));
          await tester.pumpAndSettle();

          // cancel pick
          mockImagePick(tester, canceled: true);
          await tester.tap(find.byKey(const Key('empty_body')));
          await tester.pumpAndSettle();

          expect(imagePath, isNull);

          // cancel crop
          mockImagePick(tester);
          mockImageCropper(canceled: true);
          await tester.tap(find.byKey(const Key('empty_body')));
          await tester.pumpAndSettle();

          // select successfully
          mockImagePick(tester);
          mockImageCropper();
          await tester.tap(find.byKey(const Key('empty_body')));
          await tester.pumpAndSettle();

          final pattern = RegExp('menu_image/g[0-9]{8}T[0-9]{12}');
          expect(pattern.hasMatch(imagePath!), isTrue);
          expect(XFile('$imagePath-avator').file.existsSync(), isTrue);
        });

        testWidgets('pop back', (tester) async {
          deviceAs(device, tester);
          String? result;
          await createImageAt('0');

          await tester.pumpWidget(createApp((v) => result = v));

          await tester.tap(find.text('go'));
          await tester.pumpAndSettle();

          await tester.longPress(find.byKey(const Key('image_gallery.0')));
          await tester.pumpAndSettle();
          expect(find.text(S.imageGallerySelectionTitle), findsOneWidget);

          // disable selecting
          await tester.tap(find.byKey(const Key('image_gallery.cancel')));
          await tester.pumpAndSettle();
          expect(find.text(S.imageGallerySelectionTitle), findsNothing);

          // leave
          await (device == Device.mobile
              ? tester.tap(find.byKey(const Key('image_gallery.close')))
              : tester.tapAt(Offset.zero));
          await tester.pumpAndSettle();
          expect(find.text('go'), findsOneWidget);
          expect(result, isNull);
        });

        testWidgets('select image', (tester) async {
          deviceAs(device, tester);
          String? result;
          final newImage = await createImageAt('0');

          await tester.pumpWidget(createApp((v) => result = v));

          await tester.tap(find.text('go'));
          await tester.pumpAndSettle();

          await tester.tap(find.byKey(const Key('image_gallery.0')));
          await tester.pumpAndSettle();

          expect(find.text('go'), findsOneWidget);
          expect(result, equals(newImage));
        });

        testWidgets('delete selected', (tester) async {
          deviceAs(device, tester);
          final gallery = GlobalKey<ImageGalleryPageState>();
          await createImageAt('g20230102030405111');
          await createImageAt('g20230102030405222');
          await createImageAt('g20230102030405222-avator');
          await createImageAt('g20230102030405333');

          await tester.pumpWidget(MaterialApp(
            home: ScaffoldMessenger(child: ImageGalleryPage(key: gallery)),
          ));
          await tester.pumpAndSettle();

          final selected = gallery.currentState!.selectedImages;

          await tester.longPress(find.byKey(const Key('image_gallery.0')));
          await tester.pumpAndSettle();

          // check selected first
          expect(find.byKey(const Key('image_gallery.delete')), findsOneWidget);
          expect(selected.length, equals(1));
          expect(selected.first, equals(0));

          // select second
          await tester.tap(find.byKey(const Key('image_gallery.1')));
          await tester.pumpAndSettle();
          expect(selected.length, equals(2));
          expect(selected.contains(0), isTrue);
          expect(selected.contains(1), isTrue);

          // unselect second
          await tester.tap(find.byKey(const Key('image_gallery.1')));
          await tester.pumpAndSettle();
          expect(selected.contains(1), isFalse);

          // cancel by btn
          await tester.tap(find.byKey(const Key('image_gallery.cancel')));
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('image_gallery.delete')), findsNothing);

          // check select second
          await tester.longPress(find.byKey(const Key('image_gallery.1')));
          await tester.pumpAndSettle();
          expect(selected.length, equals(1));
          expect(selected.first, equals(1));

          // delete selected
          await tester.tap(find.byKey(const Key('image_gallery.delete')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('delete_dialog.confirm')));
          await tester.pumpAndSettle();

          // remain others
          expect(find.byKey(const Key('image_gallery.0')), findsOneWidget);
          expect(find.byKey(const Key('image_gallery.1')), findsOneWidget);
          expect(find.byKey(const Key('image_gallery.2')), findsNothing);

          expect(
            gallery.currentState!.images,
            equals([
              'menu_image/g20230102030405333',
              'menu_image/g20230102030405111',
            ]),
          );

          // empty avatar is fine
          await tester.longPress(find.byKey(const Key('image_gallery.1')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('image_gallery.delete')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('delete_dialog.confirm')));
          await tester.pumpAndSettle();

          expect(
            gallery.currentState!.images,
            equals(['menu_image/g20230102030405333']),
          );
        });
      });
    }

    setUpAll(() {
      initializeTranslator();
      initializeFileSystem();
    });

    setUp(() async {
      await XFile.createDir('menu_image');
      await XFile.fs.directory('menu_image').delete(recursive: true);
      await XFile.createDir('menu_image');
    });
  });
}
