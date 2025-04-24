import 'package:flutter/material.dart';

class ThemeColors {
  static const MaterialColor success = MaterialColor(_successPrimaryValue, <int, Color>{
    50: Color(0xFFE6F9EF),
    100: Color(0xFFB8EFD2),
    200: Color(0xFF87E3B2),
    300: Color(0xFF56D792),
    400: Color(0xFF32CD7A),
    500: Color(_successPrimaryValue),
    600: Color(0xFF0AA84F),
    700: Color(0xFF089E45),
    800: Color(0xFF06953D),
    900: Color(0xFF03842C),
  });
  static const int _successPrimaryValue = 0xFF0AA553;

  static const MaterialColor successAccent = MaterialColor(_successAccentValue, <int, Color>{
    100: Color(0xFF8CFF99),
    200: Color(_successAccentValue),
    400: Color(0xFF33FF66),
    700: Color(0xFF29FF5C),
  });
  static const int _successAccentValue = 0xFF43FF43;

  static const MaterialColor info = MaterialColor(_infoPrimaryValue, <int, Color>{
    50: Color(0xFFE4F2FC),
    100: Color(0xFFB6DBF7),
    200: Color(0xFF84C2F1),
    300: Color(0xFF52A9EB),
    400: Color(0xFF2D96E6),
    500: Color(_infoPrimaryValue),
    600: Color(0xFF0275CE),
    700: Color(0xFF016BC8),
    800: Color(0xFF0161C2),
    900: Color(0xFF014DB8),
  });
  static const int _infoPrimaryValue = 0xFF0278D6;

  static const MaterialColor infoAccent = MaterialColor(_infoAccentValue, <int, Color>{
    100: Color(0xFFA3D6FF),
    200: Color(_infoAccentValue),
    400: Color(0xFF5AB3FF),
    700: Color(0xFF3AA3FF),
  });
  static const int _infoAccentValue = 0xFF53ACFF;

  static const MaterialColor warning = MaterialColor(_warningPrimaryValue, <int, Color>{
    50: Color(0xFFFFF2E0),
    100: Color(0xFFFFDCB3),
    200: Color(0xFFFFC580),
    300: Color(0xFFFFAD4D),
    400: Color(0xFFFF9C26),
    500: Color(_warningPrimaryValue),
    600: Color(0xFFF39100),
    700: Color(0xFFEA8800),
    800: Color(0xFFE17E00),
    900: Color(0xFFD46E00),
  });
  static const int _warningPrimaryValue = 0xFFED9200;

  static const MaterialColor warningAccent = MaterialColor(_warningAccentValue, <int, Color>{
    100: Color(0xFFFFEDE9),
    200: Color(_warningAccentValue),
    400: Color(0xFFFFB5A1),
    700: Color(0xFFFFA393),
  });
  static const int _warningAccentValue = 0xFFFFC5B6;

  static const MaterialColor error = MaterialColor(_errorPrimaryValue, <int, Color>{
    50: Color(0xFFFDE8E7),
    100: Color(0xFFF9C2C0),
    200: Color(0xFFF59997),
    300: Color(0xFFF0706E),
    400: Color(0xFFEC524F),
    500: Color(_errorPrimaryValue),
    600: Color(0xFFE2332D),
    700: Color(0xFFDD2B25),
    800: Color(0xFFD8231F),
    900: Color(0xFFCE150F),
  });
  static const int _errorPrimaryValue = 0xFFE0302A;

  static const MaterialColor errorAccent = MaterialColor(_errorAccentValue, <int, Color>{
    100: Color(0xFFFFC2CB),
    200: Color(_errorAccentValue),
    400: Color(0xFFFF6B82),
    700: Color(0xFFFF5B74),
  });
  static const int _errorAccentValue = 0xFFFF8294;

  static const MaterialColor primary = MaterialColor(_primaryPrimaryValue, <int, Color>{
    50: Color(0xFFF2E6E9),
    100: Color(0xFFDABAC1),
    200: Color(0xFFBE8B96),
    300: Color(0xFFA15C6B),
    400: Color(0xFF8C3A4C),
    500: Color(_primaryPrimaryValue),
    600: Color(0xFF5E1324),
    700: Color(0xFF530F1E),
    800: Color(0xFF490C18),
    900: Color(0xFF37060E),
  });
  static const int _primaryPrimaryValue = 0xFF68152A;

  static const MaterialColor primaryAccent = MaterialColor(_primaryAccentValue, <int, Color>{
    100: Color(0xFFFF2A89),
    200: Color(_primaryAccentValue),
    400: Color(0xFFD1005E),
    700: Color(0xFFC10057),
  });
  static const int _primaryAccentValue = 0xFFE50065;
}