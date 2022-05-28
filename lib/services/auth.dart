import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:possystem/helpers/logger.dart';

class Auth {
  static Auth instance = Auth();

  final GoogleSignIn _service;

  final FirebaseAuth _firebaseAuth;

  Auth([GoogleSignIn? service, FirebaseAuth? auth])
      : _service = service ?? GoogleSignIn(scopes: []),
        _firebaseAuth = auth ?? FirebaseAuth.instance;

  Future<Client?> getAuthenticatedClient({
    List<String> scopes = const [],
    @visibleForTesting GoogleSignInAuthentication? debugAuthentication,
  }) async {
    final newScopes = scopes.toSet().difference(_service.scopes.toSet());
    if (newScopes.isNotEmpty) {
      debug(newScopes.join(','), 'auth_google_scopes_needed');
      if (await _service.requestScopes(newScopes.toList())) {
        info(newScopes.join(','), 'auth_google_scopes');
        _service.scopes.addAll(newScopes);
      }
    }

    return _service.authenticatedClient(
      // ignore: invalid_use_of_visible_for_testing_member
      debugAuthentication: debugAuthentication,
    );
  }

  Future<bool> loginIfNot() async {
    final user = await _service.signInSilently();
    if (user != null && _firebaseAuth.currentUser != null) {
      return true;
    }

    try {
      info('start', 'auth.login');
      // Trigger the authentication flow
      final GoogleSignInAccount? user = await _service.signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? auth = await user?.authentication;
      info(auth == null ? 'empty' : 'allow', 'auth.login');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: auth?.accessToken,
        idToken: auth?.idToken,
      );

      // Once signed in, return the UserCredential
      await _firebaseAuth.signInWithCredential(credential);

      return true;
    } catch (e, stack) {
      error(e.toString(), 'auth', stack);
      return false;
    }
  }
}
