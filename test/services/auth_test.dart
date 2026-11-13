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
  GoogleSignInAuthorizationClient,
  GoogleSignInClientAuthorization,
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

    test('init', () async {
      when(googleSignIn.initialize()).thenAnswer((_) => Future.value(null));
      when(googleSignIn.attemptLightweightAuthentication()).thenAnswer((_) => Future.value(null));
      await auth.init();
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
        when(googleSignIn.supportsAuthenticate()).thenReturn(true);
        when(googleSignIn.authenticate()).thenAnswer((_) => Future.value(user));
        when(user.authentication).thenReturn(cred);
        when(cred.idToken).thenReturn('hi');
        when(firebaseAuth.signInWithCredential(any)).thenAnswer((_) => Future.value(MockUserCredential()));

        final success = await auth.signIn();

        expect(success, isTrue);
      });
    });

    test('#getAuthenticatedClient', () async {
      final client = MockGoogleSignInAuthorizationClient();
      final authz = MockGoogleSignInClientAuthorization();
      when(authz.accessToken).thenReturn('hello');
      when(googleSignIn.authorizationClient).thenReturn(client);
      when(client.authorizationForScopes(['a', 'b'])).thenAnswer((_) => Future.value(null));
      when(client.authorizeScopes(['a', 'b'])).thenAnswer((_) => Future.value(authz));

      final result = await auth.getAuthenticatedClient(scopes: ['a', 'b']);

      expect(result, isNotNull);
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
