import 'package:possystem/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:possystem/services/sign_in_method/sign_in_method.dart';

class SignInByGoogle extends SignInMethod<GoogleSignInAuthentication> {
  final List<String> scopes = ['email', 'profile'];

  @override
  Future<UserModel> exec({builder}) async {
    // Trigger the authentication flow
    var account = await GoogleSignIn(
      scopes: scopes,
    ).signIn();

    // Obtain the auth details from the request
    var auth = await account.authentication;

    return builder(auth);
  }
}
