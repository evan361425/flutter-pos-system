import 'package:firebase_auth/firebase_auth.dart'
    show User, FirebaseAuthException;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/auth.dart';

const _googleBlue = Color(0xff4285f4);
const _googleWhite = Color(0xffffffff);
const _googleDark = Color(0xff757575);

class SignInButton extends StatelessWidget {
  final Widget Function(User) signedInWidget;

  const SignInButton({
    Key? key,
    required this.signedInWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: Auth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        // User is not signed in
        if (user == null) {
          return const _GoogleSignInButton(key: Key('google_sign_in'));
        }

        // Render widget if authenticated
        return signedInWidget(user);
      },
    );
  }
}

class _GoogleSignInButton extends StatefulWidget {
  const _GoogleSignInButton({Key? key}) : super(key: key);

  @override
  State<_GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<_GoogleSignInButton> {
  bool isLoading = false;

  String? error;

  /// follow https://developers.google.com/identity/branding-guidelines#top_of_page
  @override
  Widget build(BuildContext context) {
    const size = 19.0;
    const padding = size * 1.33 / 2;
    const margin = (size + padding * 2) / 10;
    const height = size + padding * 2;
    const borderRadius = size / 3;
    const borderWidth = 1.0;
    const iconBorderRadius = borderRadius - borderWidth;

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final backgroundColor = isDark ? _googleBlue : _googleWhite;
    final fontColor = isDark ? _googleWhite : _googleDark;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: margin),
          child: Stack(
            children: [
              Material(
                elevation: 1,
                color: backgroundColor,
                borderRadius: BorderRadius.circular(borderRadius),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: backgroundColor),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(iconBorderRadius),
                    child: SizedBox(
                      height: height,
                      child: Row(
                        children: [
                          SizedBox(
                            width: height,
                            height: height,
                            child: SvgPicture.asset(
                              'assets/google_signin_button.svg',
                              width: size,
                              height: size,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '使用 Google 登入',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                height: 1.1,
                                color: fontColor,
                                fontSize: size,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(borderRadius),
                    onTap: signIn,
                  ),
                ),
              ),
              if (isLoading)
                const Positioned.fill(
                  child: Center(
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: CircularProgressIndicator(
                        value: size,
                        strokeWidth: borderWidth * 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }

  Future<void> signIn() async {
    if (!isLoading) {
      setState(() => isLoading = true);

      bool success = false;
      try {
        success = await Auth.instance.signIn();
      } catch (e, stack) {
        Log.err(e, 'auth_signin', stack);
        setState(() {
          error = e is FirebaseAuthException ? e.message : e.toString();
        });
      }
      // if success this widget will disposed and should not fire setState
      if (!success) setState(() => isLoading = false);
    }
  }
}
