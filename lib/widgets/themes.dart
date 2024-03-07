import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTheme {
  static ThemeData lightTheme(BuildContext context) => ThemeData(
      primarySwatch: Colors.deepPurple,
      cardColor: Colors.purple[200],
      highlightColor: Colors.deepPurpleAccent[800],
      appBarTheme: AppBarTheme(
        color: Colors.blue[900],
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
      ));

  static ThemeData darkTheme(BuildContext context) => ThemeData(
      brightness: Brightness.dark, cardColor: Colors.deepPurpleAccent[400]);
}
