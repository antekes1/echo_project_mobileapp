import 'dart:async';
import 'package:echo/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../utils/myGlobals.dart' as globals;

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String name = "";
  String password = "";
  String message = "";
  List<String> errors = [];
  final server_ip = globals.server_ip;
  bool changeButton = false;

  final _formKey = GlobalKey<FormState>();
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

        // Navigator.pushNamed(context, MyRoutes.homeRoute);
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      } //else if (responseBody.containsKey('error')) {
      //   // Błąd logowania
      //   final error = responseBody['error'];

      //   print('Błąd logowania: $error');
      // }
    } else {
      // Obsłuż błąd HTTP
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

    print(aa_value);

    if (aa_value == true) {
      String? token_value = await globals.storage.read(key: 'token');
      print('token_value: $token_value');
      if (token_value != null) {
        globals.token = token_value;
        await get_data(context);
      }
    }
  }

  moveToHome(BuildContext context) async {
    if (_formKey.currentState?.validate() == true) {
      Map data = {'username': name, "password": password};
      //encode Map to JSON

      var response = await http.post(
        Uri.parse(server_ip +
            '/auth/login'), // Tutaj przekształcamy ciąg znaków na Uri
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'username': name, 'password': password},
      );
      if (response.statusCode == 200) {
        // Odpowiedź jest poprawna
        final responseBody =
            jsonDecode(response.body); // Parsuj treść odpowiedzi JSON
        print(responseBody);
        if (responseBody.containsKey('acces_token')) {
          // Zalogowano pomyślnie
          final atoken = responseBody['acces_token'];

          print('Zalogowano pomyślnie: token=$atoken');

          if (atoken != 'None') {
            globals.token = atoken;
            await get_data(context);

            setState(() {
              changeButton = true;
              globals.storage.write(key: 'token', value: atoken);
            });

            await Future.delayed(Duration(seconds: 1));
            await Navigator.pushNamed(context, MyRoutes.homeRoute);
            setState(() {
              changeButton = false;
            });
          } else {
            print('Acces denty.');
          }
        } //else if (responseBody.containsKey('error')) {
        //   // Błąd logowania
        //   final error = responseBody['error'];

        //   print('Błąd logowania: $error');
        // }
      } else {
        // Obsłuż błąd HTTP
        print('Błąd HTTP: ${response.statusCode}');
        print('Treść odpowiedzi: ${response.body}');
        setState(() {
          errors.add("Invalid username or password");
        });
      }

      // setState(() {
      //   changeButton = true;
      // });
      // await Future.delayed(Duration(seconds: 1));
      // await Navigator.pushNamed(context, MyRoutes.homeRoute);
      // setState(() {
      //   changeButton = false;
      // });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => get_online(context));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(children: [
          Image.asset(
            "assets/images/login.png",
            fit: BoxFit.cover,
          ),
          Text(
            "Welcome $name",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 32.0,
            ),
            child: Column(
              children: [
                if (errors.isNotEmpty)
                  for (String error in errors)
                    Text(
                      error,
                      style: TextStyle(color: Colors.red),
                    ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Enter username",
                    labelText: "username",
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return "Username cannot be empty";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    name = value;
                    setState(() {});
                  },
                ),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Enter password",
                    labelText: "password",
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return "Password cannot be empty";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    password = value;
                    setState(() {});
                  },
                ),
                SizedBox(height: 20.0),
                InkWell(
                  onTap: () => moveToHome(context),
                  child: AnimatedContainer(
                    duration: Duration(seconds: 1),
                    width: changeButton ? 50 : 150,
                    height: 50,
                    alignment: Alignment.center,
                    child: changeButton
                        ? Icon(
                            Icons.done,
                            color: Colors.white,
                          )
                        : Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(changeButton ? 50 : 8),
                      color: Colors.deepPurple[900],
                    ),
                  ),
                ),
              ],
            ),
          )
        ]),
      ),
    ));
  }
}
