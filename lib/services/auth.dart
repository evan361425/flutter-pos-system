import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:possystem/helpers/logger.dart';

class Auth {
  static Auth instance = Auth();

  final GoogleSignIn _service;

  final FirebaseAuth _firebaseAuth;

  Auth([GoogleSignIn? service, FirebaseAuth? auth])
    : _service = service ?? GoogleSignIn.instance,
      _firebaseAuth = auth ?? .instance;

  Future<void> init() async {
    await _service.initialize();
    await _service.attemptLightweightAuthentication();
  }

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  Future<Client?> getAuthenticatedClient({List<String> scopes = const []}) async {
    final client = _service.authorizationClient;
    var authz = await client.authorizationForScopes(scopes);

    // missing scope for authorization
    if (authz == null) {
      Log.ger('login_scope', {'scopes': scopes.join(',')});
      authz = await client.authorizeScopes(scopes);
    }

    return authz.authClient(scopes: scopes);
  }

  Future<void> signOut() async {
    await _service.signOut();
    await _firebaseAuth.signOut();
  }

  Future<bool> signIn() async {
    var success = false;
    if (_service.supportsAuthenticate()) {
      Log.ger('login', {'loginMethod': 'google'});
      // Trigger the authentication flow
      final GoogleSignInAccount user = await _service.authenticate();

      Log.out('allow authentication', 'login');
      // Create a new credential
      final credential = GoogleAuthProvider.credential(idToken: user.authentication.idToken);

      // Once signed in, return the UserCredential
      await _firebaseAuth.signInWithCredential(credential);
      success = true;
    }

    return success;
  }
}
