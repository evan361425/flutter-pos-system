import 'package:flutter/material.dart';
import 'package:possystem/app_localizations.dart';
import 'package:possystem/providers/auth_provider.dart';
import 'package:possystem/routes.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController _emailController;
  TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: "");
    _passwordController = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          _buildBackground(),
          Align(
            alignment: Alignment.center,
            child: _buildForm(context),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildForm(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FlutterLogo(
                    size: 128,
                  ),
                ),
                TextFormField(
                  controller: _emailController,
                  style: Theme.of(context).textTheme.body1,
                  validator: (value) => value.isEmpty
                      ? AppLocalizations.of(context)
                          .translate("loginTxtErrorEmail")
                      : null,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.email,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      labelText: AppLocalizations.of(context)
                          .translate("loginTxtEmail"),
                      border: OutlineInputBorder()),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: TextFormField(
                    obscureText: true,
                    maxLength: 12,
                    controller: _passwordController,
                    style: Theme.of(context).textTheme.body1,
                    validator: (value) => value.length < 6
                        ? AppLocalizations.of(context)
                            .translate("loginTxtErrorPassword")
                        : null,
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        labelText: AppLocalizations.of(context)
                            .translate("loginTxtPassword"),
                        border: OutlineInputBorder()),
                  ),
                ),
                authProvider.status == Status.Authenticating
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : RaisedButton(
                        child: Text(
                          AppLocalizations.of(context)
                              .translate("loginBtnSignIn"),
                          style: Theme.of(context).textTheme.button,
                        ),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            FocusScope.of(context)
                                .unfocus(); //to hide the keyboard - if any

                            bool status =
                                await authProvider.signInWithEmailAndPassword(
                                    _emailController.text,
                                    _passwordController.text);

                            if (!status) {
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text(AppLocalizations.of(context)
                                    .translate("loginTxtErrorSignIn")),
                              ));
                            }
                          }
                        }),
                authProvider.status == Status.Authenticating
                    ? Center(
                        child: null,
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 48),
                        child: Center(
                            child: Text(
                          AppLocalizations.of(context)
                              .translate("loginTxtDontHaveAccount"),
                          style: Theme.of(context).textTheme.button,
                        )),
                      ),
                authProvider.status == Status.Authenticating
                    ? Center(
                        child: null,
                      )
                    : FlatButton(
                        child: Text(AppLocalizations.of(context)
                            .translate("loginBtnLinkCreateAccount")),
                        textColor: Theme.of(context).iconTheme.color,
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacementNamed(Routes.register);
                        },
                      ),
                Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    SizedBox(
                      height: 70,
                    ),
                    Text(
                      Provider.of<Flavor>(context).toString(),
                      style: Theme.of(context).textTheme.body2,
                    ),
                  ],
                )),
              ],
            ),
          ),
        ));
  }

  Widget _buildBackground() {
    return ClipPath(
      clipper: SignInCustomClipper(),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.5,
        color: Theme.of(context).iconTheme.color,
      ),
    );
  }
}

class SignInCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);

    var firstEndPoint = Offset(size.width / 2, size.height - 95);
    var firstControlPoint = Offset(size.width / 6, size.height * 0.45);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height / 2 - 50);
    var secondControlPoint = Offset(size.width, size.height + 15);

    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
