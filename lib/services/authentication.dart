import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:possystem/models/user_model.dart';
import 'package:possystem/services/sign_in_method/sign_in_method.dart';

abstract class Authentication extends ChangeNotifier {
  AuthStatus _status = AuthStatus.Unauthenticated;

  AuthStatus get status => _status;

  set status(AuthStatus value) {
    _status = value;
    notifyListeners();
  }

  Stream<UserModel> get user;
  Future<UserModel> signIn(BuildContext context, SignInMethod method);
  Future<void> signOut();
}

/// The UI will depends on the Status to decide which screen/action to be done.
///
/// - Uninitialized - Checking user is logged or not, the Splash Screen will be shown
/// - Authenticated - User is authenticated successfully, Home Page will be shown
/// - Authenticating - Sign In button just been pressed, progress bar will be shown
///- Unauthenticated - User is not authenticated, login page will be shown
///- Failed - Authentication failed by any reason

enum AuthStatus {
  Uninitialized,
  Authenticated,
  Authenticating,
  Unauthenticated,
  Failed
}
