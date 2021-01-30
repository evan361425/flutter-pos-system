import 'package:flutter/material.dart';
import 'package:possystem/constants/app_font_family.dart';

class AppThemes {
  AppThemes._();

  //constants color range for light theme
  static const Color _lightPrimaryColor = Colors.black;
  static const Color _lightPrimaryVariantColor = Colors.white;
  static const Color _lightSecondaryColor = Colors.green;
  static const Color _lightOnPrimaryColor = Colors.black;
  static const Color _lightButtonPrimaryColor = Colors.orangeAccent;
  static const Color _lightAppBarColor = Colors.orangeAccent;
  static Color _lightIconColor = Colors.orangeAccent;
  static Color _lightSnackBarBackgroundErrorColor = Colors.redAccent;

  //text theme for light theme
  static final TextStyle _lightTextStyle =
      TextStyle(color: _lightOnPrimaryColor);
  static final TextStyle _lightTaskDurationTextStyle =
      TextStyle(fontSize: 14.0, color: Colors.grey);
  static final TextStyle _lightButtonTextStyle =
      _lightTextStyle.copyWith(fontSize: 14.0, fontWeight: FontWeight.w500);
  static final TextStyle _lightCaptionTextStyle = TextStyle(
      fontSize: 12.0, color: _lightAppBarColor, fontWeight: FontWeight.w100);

  static final TextTheme _lightTextTheme = TextTheme(
    headline1: _lightTextStyle.copyWith(fontSize: 40),
    headline2: _lightTextStyle.copyWith(fontSize: 36),
    headline3: _lightTextStyle.copyWith(fontSize: 32),
    headline4: _lightTextStyle.copyWith(fontSize: 28),
    headline5: _lightTextStyle.copyWith(fontSize: 24),
    headline6: _lightTextStyle.copyWith(fontSize: 20),
    bodyText1: _lightTextStyle.copyWith(fontSize: 16),
    bodyText2: _lightTaskDurationTextStyle,
    subtitle1: _lightTextStyle.copyWith(fontSize: 16),
    button: _lightButtonTextStyle,
    caption: _lightCaptionTextStyle,
  );

  //constants color range for dark theme
  static const Color _darkPrimaryColor = Colors.white;
  static const Color _darkPrimaryVariantColor = Colors.black;
  static const Color _darkSecondaryColor = Colors.white;
  static const Color _darkOnPrimaryColor = Colors.white;
  static const Color _darkButtonPrimaryColor = Colors.deepPurpleAccent;
  static const Color _darkAppBarColor = Colors.deepPurpleAccent;
  static Color _darkIconColor = Colors.deepPurpleAccent;
  static Color _darkSnackBarBackgroundErrorColor = Colors.redAccent;

  //text theme for dark theme
  static final TextStyle _darkTextStyle = TextStyle(color: _darkOnPrimaryColor);
  static final TextStyle _darkTaskDurationTextStyle =
      _lightTaskDurationTextStyle;
  static final TextStyle _darkButtonTextStyle = TextStyle(
      fontSize: 14.0, color: _darkOnPrimaryColor, fontWeight: FontWeight.w500);
  static final TextStyle _darkCaptionTextStyle = TextStyle(
      fontSize: 12.0, color: _darkAppBarColor, fontWeight: FontWeight.w100);

  static final TextTheme _darkTextTheme = TextTheme(
    headline1: _darkTextStyle.copyWith(fontSize: 40),
    headline2: _darkTextStyle.copyWith(fontSize: 36),
    headline3: _darkTextStyle.copyWith(fontSize: 32),
    headline4: _darkTextStyle.copyWith(fontSize: 28),
    headline5: _darkTextStyle.copyWith(fontSize: 24),
    headline6: _darkTextStyle.copyWith(fontSize: 20),
    bodyText1: _darkTextStyle.copyWith(fontSize: 16),
    bodyText2: _darkTaskDurationTextStyle,
    subtitle1: _darkTextStyle.copyWith(fontSize: 16),
    button: _darkButtonTextStyle,
    caption: _darkCaptionTextStyle,
  );

  //the light theme
  static final ThemeData lightTheme = ThemeData(
    fontFamily: AppFontFamily.productSans,
    scaffoldBackgroundColor: _lightPrimaryVariantColor,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightButtonPrimaryColor,
    ),
    appBarTheme: AppBarTheme(
      color: _lightAppBarColor,
      iconTheme: IconThemeData(color: _lightOnPrimaryColor),
      textTheme: _lightTextTheme,
    ),
    colorScheme: ColorScheme.light(
      primary: _lightPrimaryColor,
      primaryVariant: _lightPrimaryVariantColor,
      secondary: _lightSecondaryColor,
      onPrimary: _lightOnPrimaryColor,
    ),
    snackBarTheme:
        SnackBarThemeData(backgroundColor: _lightSnackBarBackgroundErrorColor),
    iconTheme: IconThemeData(
      color: _lightIconColor,
    ),
    popupMenuTheme: PopupMenuThemeData(color: _lightAppBarColor),
    textTheme: _lightTextTheme,
    buttonTheme: ButtonThemeData(
        buttonColor: _lightButtonPrimaryColor,
        textTheme: ButtonTextTheme.primary),
    unselectedWidgetColor: _lightPrimaryColor,
    inputDecorationTheme: InputDecorationTheme(
      fillColor: _lightPrimaryColor,
      labelStyle: TextStyle(
        color: _lightPrimaryColor,
      ),
    ),
  );

  //the dark theme
  static final ThemeData darkTheme = ThemeData(
    fontFamily: AppFontFamily.productSans,
    scaffoldBackgroundColor: _darkPrimaryVariantColor,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkButtonPrimaryColor,
    ),
    appBarTheme: AppBarTheme(
      color: _darkAppBarColor,
      iconTheme: IconThemeData(color: _darkOnPrimaryColor),
      textTheme: _darkTextTheme,
    ),
    colorScheme: ColorScheme.light(
      primary: _darkPrimaryColor,
      primaryVariant: _darkPrimaryVariantColor,
      secondary: _darkSecondaryColor,
      onPrimary: _darkOnPrimaryColor,
    ),
    snackBarTheme:
        SnackBarThemeData(backgroundColor: _darkSnackBarBackgroundErrorColor),
    iconTheme: IconThemeData(
      color: _darkIconColor,
    ),
    popupMenuTheme: PopupMenuThemeData(color: _darkAppBarColor),
    textTheme: _darkTextTheme,
    buttonTheme: ButtonThemeData(
        buttonColor: _darkButtonPrimaryColor,
        textTheme: ButtonTextTheme.primary),
    unselectedWidgetColor: _darkPrimaryColor,
    inputDecorationTheme: InputDecorationTheme(
      fillColor: _darkPrimaryColor,
      labelStyle: TextStyle(
        color: _darkPrimaryColor,
      ),
    ),
  );
}
