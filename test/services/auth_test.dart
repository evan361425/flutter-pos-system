import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/services/auth.dart';

import '../test_helpers/firebase_mocker.dart';
import 'auth_test.mocks.dart';

// Custom Mock! avoid clean up after rebuild
@GenerateMocks([
  GoogleSignIn,
  FirebaseAuth,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  User,
  UserCredential,
])
void main() {
  group('Auth', () {
    late Auth auth;
    late MockGoogleSignIn googleSignIn;
    late MockFirebaseAuth firebaseAuth;

    test('construct', () async {
      setupFirebaseAuthMocks();

      await Firebase.initializeApp();

      Auth();
    });

    test('#authStateChanges', () async {
      when(firebaseAuth.authStateChanges()).thenAnswer((_) => Stream.value(null));

      final result = await auth.authStateChanges().first;

      expect(result, isNull);
    });

    group('#signIn -', () {
      test('success', () async {
        final user = MockGoogleSignInAccount();
        final cred = MockGoogleSignInAuthentication();
        when(googleSignIn.signIn()).thenAnswer((_) => Future.value(user));
        when(user.authentication).thenAnswer((_) => Future.value(cred));
        when(cred.accessToken).thenReturn('hi');
        when(cred.idToken).thenReturn('there');
        when(firebaseAuth.signInWithCredential(any)).thenAnswer((_) => Future.value(MockUserCredential()));

        final success = await auth.signIn();

        expect(success, isTrue);
      });

      test('empty google user', () async {
        when(googleSignIn.signIn()).thenAnswer((_) => Future.value());

        final success = await auth.signIn();

        expect(success, isFalse);
      });
    });

    test('#getAuthenticatedClient', () async {
      final scopes = ['a'];
      final cred = MockGoogleSignInAuthentication();
      when(cred.accessToken).thenReturn(null);
      when(googleSignIn.signInSilently()).thenAnswer((_) => Future.value());
      when(googleSignIn.scopes).thenReturn(scopes);
      when(googleSignIn.requestScopes(['b', 'c'])).thenAnswer((_) => Future.value(true));

      final result = await auth.getAuthenticatedClient(
        scopes: ['a', 'b', 'c'],
        debugAuthentication: cred,
      );

      expect(result, isNull);
      expect(scopes, equals(['a', 'b', 'c']));
    });

    test('#signOut', () async {
      when(googleSignIn.signOut()).thenAnswer((_) => Future.value(null));
      when(firebaseAuth.signOut()).thenAnswer((_) => Future.value(null));
      await auth.signOut();
    });

    setUp(() {
      googleSignIn = MockGoogleSignIn();
      firebaseAuth = MockFirebaseAuth();
      auth = Auth(googleSignIn, firebaseAuth);
    });
  });
}
