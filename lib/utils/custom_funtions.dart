import 'package:flutter/material.dart';
import 'package:echo/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../utils/myGlobals.dart' as globals;
import 'package:flutter/cupertino.dart';
import 'package:echo/utils/routes.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/CustomFABRow.dart';
import 'package:connectivity/connectivity.dart';

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

final server_ip = globals.server_ip;

bool aa_value = false;

get_online(BuildContext context) async {
  try {
    var response = await http.get(
      Uri.parse(
          server_ip + '/status'), // Tutaj przekształcamy ciąg znaków na Uri
      headers: {"Content-Type": "application/json"},
    );
    final responseBody = jsonDecode(response.body);
    print("Odpowiedź: $responseBody");
    return true;
  } catch (e) {
    print(e);
    Navigator.pushNamedAndRemoveUntil(
      context,
      MyRoutes.NonetRoute,
      (route) => false,
    );
  }
}
