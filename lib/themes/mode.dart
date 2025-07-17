import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.grey.shade100,
  colorScheme: ColorScheme.light(
    surface: Colors.white,
    primary: Color(0xFFD0C4BB),
    onPrimary: Color(0xFFB5A199),
    secondary: Color(0xFF998173),
    onSecondary: Color(0xFF866859),
    tertiary: Color(0xFF71503D),
    onTertiary: Color(0xFF644839),
  ),
  textTheme: TextTheme(
    bodyMedium: TextStyle(
      color: Colors.black,
    ),
  ),
);



ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Color(0xFF171717) ,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    primary: Colors.grey.shade800,
    onPrimary: Colors.white,
    secondary: Colors.grey.shade700,
    onSecondary: Colors.grey.shade800,

  ),
  textTheme: TextTheme(
    bodyMedium: TextStyle(
      color: Color(0xFFD9D9D9),
    ),
  ),
);