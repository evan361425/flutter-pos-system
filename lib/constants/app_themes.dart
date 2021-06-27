import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';

/// Want to build your own theme?
/// https://github.com/rxlabz/panache
class AppThemes {
  static final TextTheme _lightTextTheme = TextTheme(
    headline1: TextStyle(color: Color(0xdd000000), fontSize: 40),
    headline2: TextStyle(color: Color(0xdd000000), fontSize: 36),
    headline3: TextStyle(color: Color(0xdd000000), fontSize: 32),
    headline4: TextStyle(color: Color(0xdd000000), fontSize: 28),
    headline5: TextStyle(color: Color(0xdd000000), fontSize: 24),
    headline6: TextStyle(color: Color(0xdd000000), fontSize: 20),
    subtitle1: TextStyle(color: Color(0xdd000000), fontSize: 16),
    subtitle2: TextStyle(color: Color(0xdd000000), fontSize: 12),
    bodyText1: TextStyle(color: Color(0xdd000000)),
    bodyText2: TextStyle(color: Color(0xdd000000)),
    button: TextStyle(color: Color(0xdd000000)),
    overline: TextStyle(color: Color(0xff000000)),
  );

  static final TextTheme _darkTextTheme = TextTheme(
    headline1: TextStyle(color: Color(0xb3ffffff), fontSize: 40),
    headline2: TextStyle(color: Color(0xb3ffffff), fontSize: 36),
    headline3: TextStyle(color: Color(0xb3ffffff), fontSize: 32),
    headline4: TextStyle(color: Color(0xb3ffffff), fontSize: 28),
    headline5: TextStyle(color: Color(0xb3ffffff), fontSize: 24),
    headline6: TextStyle(color: Color(0xb3ffffff), fontSize: 20),
    subtitle1: TextStyle(color: Color(0xffffffff), fontSize: 16),
    subtitle2: TextStyle(color: Color(0xffffffff), fontSize: 12),
    bodyText1: TextStyle(color: Color(0xffffffff)),
    bodyText2: TextStyle(color: Color(0xffffffff)),
    button: TextStyle(color: Color(0xffffffff)),
    overline: TextStyle(color: Color(0xffffffff)),
  );

  static final ThemeData lightTheme = ThemeData(
    appBarTheme: AppBarTheme(
      centerTitle: true,
      color: Color(0xfffafafa),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xffff9800),
      foregroundColor: Color(0xffffffff),
    ),
    primarySwatch: Colors.amber,
    brightness: Brightness.light,
    primaryColor: Color(0xffffc107),
    primaryColorBrightness: Brightness.light,
    primaryColorLight: Color(0xffffecb3),
    primaryColorDark: Color(0xff673ab7),
    // buttonColor: Color(0x8a000000),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: Color(0xffffe082),
      cursorColor: Color(0xff4285f4),
      selectionHandleColor: Color(0xffffd54f),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(primary: Color(0xdd000000)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(primary: Color(0xdd000000)),
    ),
    buttonTheme: ButtonThemeData(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing2),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Color(0xff000000),
          width: 0,
          style: BorderStyle.none,
        ),
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    ),
    textTheme: _lightTextTheme,
    primaryTextTheme: _lightTextTheme,
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(color: Color(0xdd000000)),
      helperStyle: TextStyle(color: Color(0xdd000000)),
      hintStyle: TextStyle(color: Color(0xdd000000).withOpacity(0.5)),
      errorStyle: TextStyle(color: kNegativeColor),
      contentPadding: const EdgeInsets.all(kSpacing1),
      prefixStyle: TextStyle(color: Color(0xdd000000)),
      suffixStyle: TextStyle(color: Color(0xdd000000)),
      counterStyle: TextStyle(color: Color(0xdd000000)),
      filled: true,
      fillColor: Color(0x0a000000),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xff000000)),
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xff000000)),
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      disabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xff000000)),
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xff000000)),
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xff000000)),
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    ),
    iconTheme: IconThemeData(
      color: Color(0xdd000000),
      size: 24,
    ),
    primaryIconTheme: IconThemeData(
      color: Color(0xff000000),
      size: 24,
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Color(0xff000000)),
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    appBarTheme: AppBarTheme(
      centerTitle: true,
      color: Color(0xff303030),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xff512da8),
      foregroundColor: Color(0xffffffff),
    ),
    primarySwatch: Colors.deepPurple,
    brightness: Brightness.dark,
    primaryColor: Color(0xff673ab7),
    primaryColorBrightness: Brightness.dark,
    primaryColorLight: Color(0xff9e9e9e),
    primaryColorDark: Color(0xff2196f3),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: Color(0xff64ffda),
      cursorColor: Color(0xff4285f4),
      selectionHandleColor: Color(0xff1de9b6),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(primary: Color(0xffffffff)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(primary: Color(0xffffffff)),
    ),
    buttonTheme: ButtonThemeData(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing2),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Color(0xff000000),
          width: 0,
          style: BorderStyle.none,
        ),
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    ),
    textTheme: _darkTextTheme,
    primaryTextTheme: _darkTextTheme,
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(color: Color(0xffffffff)),
      helperStyle: TextStyle(color: Color(0xffffffff)),
      hintStyle: TextStyle(color: Color(0xffffffff).withOpacity(0.5)),
      errorStyle: TextStyle(color: kNegativeColor),
      contentPadding: const EdgeInsets.all(kSpacing1),
      prefixStyle: TextStyle(color: Color(0xffffffff)),
      suffixStyle: TextStyle(color: Color(0xffffffff)),
      counterStyle: TextStyle(color: Color(0xffffffff)),
      filled: false,
      fillColor: Color(0x00000000),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xff000000)),
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xff000000)),
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      disabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xff000000)),
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xff000000)),
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xff000000)),
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    ),
    iconTheme: IconThemeData(
      color: Color(0xffffffff),
      size: 24,
    ),
    primaryIconTheme: IconThemeData(
      color: Color(0xffffffff),
      size: 24,
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Color(0xff000000)),
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    ),
  );

  // Avoid someone build the instance
  AppThemes._();
}
