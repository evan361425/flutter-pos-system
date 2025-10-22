import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/auth.dart';
import 'package:possystem/services/chat_service.dart';
import 'package:possystem/settings/language_setting.dart';
import 'package:possystem/ui/home/chat_page.dart';

import '../../mocks/mock_auth.dart';
import '../../services/auth_test.mocks.dart';
import '../../test_helpers/firebase_mocker.dart';
import '../../test_helpers/translator.dart';
import 'chat_page_test.mocks.dart';

@GenerateMocks([FirebaseFirestore, CollectionReference, Query, QuerySnapshot, DocumentReference, DocumentSnapshot])
void main() {
  group('Chat Page', () {
    late MockFirebaseFirestore mockFirestore;
    late StreamController<User?> authController;
    late MockUser mockUser;

    Widget buildApp() {
      return MaterialApp.router(
        locale: LanguageSetting.instance.language.locale,
        routerConfig: GoRouter(
          navigatorKey: Routes.rootNavigatorKey,
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => const Scaffold(body: ChatPage()),
            ),
          ],
        ),
      );
    }

    testWidgets('should show sign in required when not authenticated', (tester) async {
      authController.add(null);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.login), findsOneWidget);
      expect(find.text('Please sign in to start chatting'), findsOneWidget);
    });

    testWidgets('should show loading when authenticated', (tester) async {
      when(mockUser.uid).thenReturn('test_uid');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.displayName).thenReturn('Test User');
      
      authController.add(mockUser);

      await tester.pumpWidget(buildApp());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show FAQ dialog when FAQ button tapped', (tester) async {
      when(mockUser.uid).thenReturn('test_uid');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.displayName).thenReturn('Test User');
      
      authController.add(mockUser);

      // Mock Firestore for room creation
      final mockCollectionRef = MockCollectionReference<Map<String, dynamic>>();
      final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
      final mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();

      when(mockFirestore.collection('chat_rooms')).thenReturn(mockCollectionRef);
      when(mockCollectionRef.doc(any)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer((_) => Future.value(mockDocSnapshot));
      when(mockDocSnapshot.exists).thenReturn(false);
      when(mockDocRef.set(any, any)).thenAnswer((_) => Future.value());

      when(mockFirestore.collection('chat_messages')).thenReturn(mockCollectionRef);
      when(mockCollectionRef.where(any, isEqualTo: anyNamed('isEqualTo'))).thenReturn(mockQuery);
      when(mockQuery.orderBy(any, descending: anyNamed('descending'))).thenReturn(mockQuery);
      when(mockQuery.limit(any)).thenReturn(mockQuery);
      when(mockQuery.snapshots()).thenAnswer((_) => Stream.value(mockQuerySnapshot));
      when(mockQuerySnapshot.docs).thenReturn([]);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Tap FAQ button
      await tester.tap(find.byKey(const Key('chat.faq')));
      await tester.pumpAndSettle();

      expect(find.text('Frequently Asked Questions'), findsOneWidget);
      expect(find.text('How can I request a new feature?'), findsOneWidget);
    });

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockUser = MockUser();
      authController = StreamController<User?>.broadcast();
      
      reset(auth);
      when(auth.authStateChanges()).thenAnswer((_) => authController.stream);

      // Initialize chat service with mock
      ChatService.instance = ChatService(mockFirestore, FirebaseAuth.instance);
    });

    tearDown(() {
      authController.close();
    });

    setUpAll(() async {
      setupFirebaseAuthMocks();
      await Firebase.initializeApp();
      initializeAuth();
      initializeTranslator();
    });
  });
}
