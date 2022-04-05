import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:possystem/helpers/logger.dart';

class Auth {
  static Auth instance = Auth._();

  Auth._();

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: []);

  Future<Client?> getAuthenticatedClient({
    List<String> scopes = const [],
  }) async {
    final newScopes = scopes.toSet().difference(_googleSignIn.scopes.toSet());
    if (newScopes.isNotEmpty) {
      debug(newScopes.join(','), 'auth.request_scopes');
      if (await _googleSignIn.requestScopes(newScopes.toList())) {
        info(newScopes.join(','), 'auth.new_scopes');
        _googleSignIn.scopes.addAll(newScopes);
      }
    }

    return _googleSignIn.authenticatedClient();
  }

  Future<bool> loginIfNot() async {
    final user = await _googleSignIn.signInSilently();
    if (user != null && FirebaseAuth.instance.currentUser != null) {
      return true;
    }

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? user = await _googleSignIn.signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? auth = await user?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: auth?.accessToken,
        idToken: auth?.idToken,
      );

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);

      return true;
    } catch (e, stack) {
      error(e.toString(), 'auth', stack);
      return false;
    }
  }
}
