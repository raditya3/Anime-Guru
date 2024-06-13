import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  primarySwatch: Colors.blue,
  // Color(0xff5e69ee),
  fontFamily: 'Lato',
  textTheme: const TextTheme(
      labelLarge: TextStyle(
          fontFamily: 'Lato',
          fontSize: 32.0,
          color: Color(0xFFF4F4FB)
      ),
      labelSmall : TextStyle(
          fontFamily: 'Lato',
          fontSize: 10.0,
          color: Color(0xFFF4F4FB)
      ),
    headlineLarge: TextStyle(
        fontFamily: 'Lato',
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: Color(0xFFF4F4FB)
    ),
    titleLarge: TextStyle(
      fontFamily: 'Lato',
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: Color(0xFFF4F4FB)
    ),
    titleMedium: TextStyle(
        fontFamily: 'Lato',
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: Color(0xFFF4F4FB)
    ),
      bodySmall : TextStyle(
          fontFamily: 'Lato',
          fontSize: 10.0,
          color: Color(0xFF737272)
      ),
  ),
  colorScheme: const ColorScheme.light(

      surface: Color(0xff5e69ee),
      primary: Color(0xff5e69ee),
      secondary: Color(0xFFF4F4FB),
      tertiary: Colors.white,
      inversePrimary: Color(0xFF39AFEA)),
);
