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

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  Future<Client?> getAuthenticatedClient({
    List<String> scopes = const [],
    @visibleForTesting GoogleSignInAuthentication? debugAuthentication,
  }) async {
    await _service.signInSilently();

    final newScopes = scopes.toSet().difference(_service.scopes.toSet());
    if (newScopes.isNotEmpty) {
      Log.ger('scopes start', 'auth_google', newScopes.join(','));
      if (await _service.requestScopes(newScopes.toList())) {
        Log.ger('scopes success', 'auth_google');
        _service.scopes.addAll(newScopes);
      }
    }

    return _service.authenticatedClient(
      // ignore: invalid_use_of_visible_for_testing_member
      debugAuthentication: debugAuthentication,
    );
  }

  Future<void> signOut() async {
    await _service.signOut();
    await _firebaseAuth.signOut();
  }

  Future<bool> signIn() async {
    Log.ger('start', 'auth_signin');
    // Trigger the authentication flow
    final GoogleSignInAccount? user = await _service.signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? auth = await user?.authentication;
    if (auth == null) {
      Log.ger('empty', 'auth_signin');
      return false;
    }

    Log.ger('allow', 'auth_signin');
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );

    // Once signed in, return the UserCredential
    await _firebaseAuth.signInWithCredential(credential);

    return true;
  }
}
