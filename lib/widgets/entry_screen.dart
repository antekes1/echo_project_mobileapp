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

class Entry_screen extends StatefulWidget {
  @override
  State<Entry_screen> createState() => _CreateStoragesPageState();
}

class _CreateStoragesPageState extends State<Entry_screen> {
  String atoken = globals.token;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String username = globals.username;
  bool changeButton = false;

  final server_ip = globals.server_ip;

  bool aa_value = false;

  get_data(BuildContext context) async {
    var response = await http.get(
      Uri.parse(server_ip +
          '/user/' +
          globals.token), // Tutaj przekształcamy ciąg znaków na Uri
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      // Odpowiedź jest poprawna
      final responseBody =
          jsonDecode(response.body); // Parsuj treść odpowiedzi JSON

      if (responseBody.containsKey('username')) {
        // Zalogowano pomyślnie
        setState(() {
          globals.username = responseBody['username'];
          globals.name = responseBody['name'];
          globals.email = responseBody['email'];
          globals.profile_pic =
              server_ip + "/photo/" + responseBody['profile_pic'];
        });
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      }
    } else {
      print('Błąd HTTP: ${response.statusCode}');
      print('Treść odpowiedzi: ${response.body}');
    }
  }

  get_online(BuildContext context) async {
    try {
      var response = await http.get(
        Uri.parse(
            server_ip + '/status'), // Tutaj przekształcamy ciąg znaków na Uri
        headers: {"Content-Type": "application/json"},
      );
      final responseBody = jsonDecode(response.body);
      print("Odpowiedź: $responseBody");
      aa_value = true;
    } catch (e) {
      print(e);
      Navigator.pushNamedAndRemoveUntil(
        context,
        MyRoutes.NonetRoute,
        (route) => false,
      );
    }

    if (aa_value == true) {
      String? token_value = await globals.storage.read(key: 'token');
      print('token_value: $token_value');
      if (token_value != null) {
        globals.token = token_value;
        await get_data(context);
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          MyRoutes.loginRoute,
          (route) => false,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => get_online(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
