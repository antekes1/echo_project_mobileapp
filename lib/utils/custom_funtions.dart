import 'package:flutter/material.dart';

String replaceMissingCharactersWithUnicode(String input) {
  StringBuffer result = StringBuffer();

  for (int codePoint in input.runes) {
    if (codePoint > 127) {
      // Jeśli znak nie mieści się w standardzie ASCII
      // Zamień go na kod Unicode
      result.write('\\u${codePoint.toRadixString(16).padLeft(4, '0')}');
    } else {
      // Znak standardowy ASCII
      result.write(String.fromCharCode(codePoint));
    }
  }

  return result.toString();
}
