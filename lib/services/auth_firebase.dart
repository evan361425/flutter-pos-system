import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:possystem/models/user_model.dart';
import 'package:possystem/services/authentication.dart';
import 'package:possystem/services/sign_in_method/sign_in_method.dart';
import 'package:possystem/services/sign_in_method/sign_in_by_google.dart';
import 'package:provider/provider.dart';

class AuthFirebase extends Authentication {
  // Firebase Auth object
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthFirebase() {
    // listener for authentication changes such as user sign in and sign out
    _auth.authStateChanges().listen(onAuthStateChanged);
  }

  Future<void> onAuthStateChanged(User user) async {
    status =
        user == null ? AuthStatus.Unauthenticated : AuthStatus.Authenticated;
  }

  // Method to detect live auth changes such as user sign in and sign out
  @override
  Stream<UserModel> get user => _auth.authStateChanges().map(_parseUser);

  // Method to handle user signing out
  @override
  Future<UserModel> signIn(BuildContext context, SignInMethod method) async {
    try {
      // No need change status after sign-in, since we listen on the event.
      status = AuthStatus.Authenticating;

      if (method is SignInByGoogle) {
        return await method.exec(builder: _signInByGoogle);
      } else {
        throw UnimplementedError();
      }
    } catch (e) {
      context.read<Logger>().e('[SignIn] Error - $e');
      status = AuthStatus.Failed;
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    status = AuthStatus.Unauthenticated;
  }

  // METHODs

  Future<UserModel> _signInByGoogle(GoogleSignInAuthentication auth) async {
    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );

    // Once signed in, return the UserCredential
    final result = await _auth.signInWithCredential(credential);

    return _parseUser(result.user);
  }

  // TOOLS

  UserModel _parseUser(User user) {
    if (user == null) {
      return null;
    }

    Logger().i('User - ${user.uid}');

    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
      photoUrl: user.photoURL,
    );
  }
}
