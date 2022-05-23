// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/services/auth.dart';

import 'auth_test_mocks.dart';

// Custom Mock! avoid clean up after rebuild
// @GenerateMocks([
//   GoogleSignIn,
//   FirebaseAuth,
//   GoogleSignInAccount,
//   GoogleSignInAuthentication,
//   User,
//   UserCredential,
//   FirebasePlatform,
//   FirebaseAppPlatform,
// ])
void main() {
  group('Auth', () {
    late Auth auth;
    late MockGoogleSignIn googleSignIn;
    late MockFirebaseAuth firebaseAuth;

    test('construct', () {
      final delegate = MockFirebasePlatform();
      final app = MockFirebaseAppPlatform();
      Firebase.delegatePackingProperty = delegate;
      when(delegate.app()).thenReturn(app);
      when(app.name).thenReturn('[DEFAULT]');

      Auth();
    });

    group('#loginIfNot -', () {
      test('ignore if already login', () async {
        when(firebaseAuth.currentUser).thenReturn(MockUser());
        when(googleSignIn.signInSilently())
            .thenAnswer((_) => Future.value(MockGoogleSignInAccount()));

        final success = await auth.loginIfNot();

        expect(success, isTrue);
      });

      test('success', () async {
        final user = MockGoogleSignInAccount();
        final cred = MockGoogleSignInAuthentication();
        when(googleSignIn.signInSilently()).thenAnswer((_) => Future.value());
        when(googleSignIn.signIn()).thenAnswer((_) => Future.value(user));
        when(user.authentication).thenAnswer((_) => Future.value(cred));
        when(cred.accessToken).thenReturn('hi');
        when(cred.idToken).thenReturn('there');
        when(firebaseAuth.signInWithCredential(any))
            .thenAnswer((_) => Future.value(MockUserCredential()));

        final success = await auth.loginIfNot();

        expect(success, isTrue);
      });

      test('failed', () async {
        when(googleSignIn.signInSilently()).thenAnswer((_) => Future.value());
        when(googleSignIn.signIn()).thenAnswer((_) => Future.value());
        when(firebaseAuth.signInWithCredential(any)).thenThrow('hi');

        final success = await auth.loginIfNot();

        expect(success, isFalse);
      });
    });

    test('#getAuthenticatedClient', () async {
      final scopes = ['a'];
      final cred = MockGoogleSignInAuthentication();
      when(cred.accessToken).thenReturn(null);
      when(googleSignIn.scopes).thenReturn(scopes);
      when(googleSignIn.requestScopes(['b', 'c']))
          .thenAnswer((_) => Future.value(true));

      final result = await auth.getAuthenticatedClient(
        scopes: ['a', 'b', 'c'],
        debugAuthentication: cred,
      );

      expect(result, isNull);
      expect(scopes, equals(['a', 'b', 'c']));
    });

    setUp(() {
      googleSignIn = MockGoogleSignIn();
      firebaseAuth = MockFirebaseAuth();
      auth = Auth(googleSignIn, firebaseAuth);
    });
  });
}
