import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:possystem/models/user_model.dart';

enum Status {
  Uninitialized,
  Authenticated,
  Authenticating,
  Unauthenticated,
  Failed
}
/*
The UI will depends on the Status to decide which screen/action to be done.

- Uninitialized - Checking user is logged or not, the Splash Screen will be shown
- Authenticated - User is authenticated successfully, Home Page will be shown
- Authenticating - Sign In button just been pressed, progress bar will be shown
- Unauthenticated - User is not authenticated, login page will be shown
- Failed - Authentication failed by any reason
*/

class AuthProvider extends ChangeNotifier {
  //Firebase Auth object
  FirebaseAuth _auth;

  //Default status
  Status _status = Status.Uninitialized;

  Status get status => _status;

  Stream<UserModel> get user => _auth.authStateChanges().map(_userFromFirebase);

  AuthProvider() {
    //initialise object
    _auth = FirebaseAuth.instance;

    //listener for authentication changes such as user sign in and sign out
    _auth.authStateChanges().listen(onAuthStateChanged);
  }

  //Create user object based on the given User
  UserModel _userFromFirebase(User user) {
    if (user == null) {
      return null;
    }

    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
      photoUrl: user.photoURL
    );
  }

  //Method to detect live auth changes such as user sign in and sign out
  Future<void> onAuthStateChanged(User user) async {
    if (user == null) {
      _status = Status.Unauthenticated;
    } else {
      _userFromFirebase(user);
      _status = Status.Authenticated;
    }
    notifyListeners();
  }

  //Method for google sign-in
  Future<UserModel> signInByGoogle(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();

      // Trigger the authentication flow
      final GoogleSignInAccount account = await GoogleSignIn(
        scopes: [ 'email', 'profile' ],
      ).signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication auth = await account.authentication;

      // Create a new credential
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential result = await _auth.signInWithCredential(credential);

      return _userFromFirebase(result.user);
    } catch (e) {
      print("Error on the google registration = " +e.toString());
      _status = Status.Failed;
      notifyListeners();
      return null;
    }
  }

  //Method to handle user signing out
  Future signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }
}
