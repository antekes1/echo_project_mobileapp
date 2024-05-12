import 'dart:async';
import 'package:echo/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/myGlobals.dart' as globals;

class ResetPasswordPage extends StatefulWidget {
  @override
  State<ResetPasswordPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<ResetPasswordPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String email = "";
  String verification_code = "";
  String password = "";
  String password2 = "";
  String message = "";
  List<String> errors = [];
  final server_ip = globals.server_ip;
  bool changeButton = false;

  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  bool aa_value = false;

  send_verification_code(BuildContext context) async {
    if (_formKey2.currentState?.validate() == true) {
      Map data = {
        'email': email,
      };
      var body = json.encode(data);
      var response = await http.post(
          Uri.parse(server_ip + '/auth/create_verification_request'),
          headers: {"Content-Type": "application/json"},
          body: body);

      if (response.statusCode == 200) {
        // Odpowiedź jest poprawna
        final responseBody =
            jsonDecode(response.body); // Parsuj treść odpowiedzi JSON
        if (responseBody.containsKey('msg')) {
          final snackBar = SnackBar(
            content: Text(
              "succes",
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.black,
            elevation: 0.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.deepPurple, width: 2)),
            behavior: SnackBarBehavior.floating,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        // Obsłuż błąd HTTP
        print('Błąd HTTP: ${response.statusCode}');
        print('Treść odpowiedzi: ${response.body}');
        setState(() {
          errors.add(response.body);
        });
      }
    }
  }

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
          globals.account_type = responseBody['account_type'];
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

  moveToHome(BuildContext context) async {
    if (_formKey.currentState?.validate() == true) {
      if (_formKey2.currentState?.validate() == true) {
        Map data = {
          "email": email,
          "new_password": password,
          "veryfication_code": verification_code
        };
        var body = json.encode(data);
        var response = await http.post(
            Uri.parse(server_ip +
                '/auth/reset_password/'), // Tutaj przekształcamy ciąg znaków na Uri
            headers: {"Content-Type": "application/json"},
            body: body);
        if (response.statusCode == 200) {
          // Odpowiedź jest poprawna
          final responseBody =
              jsonDecode(response.body); // Parsuj treść odpowiedzi JSON
          if (responseBody.containsKey('msg')) {
            await Future.delayed(Duration(seconds: 1));
            await Navigator.pushNamed(context, MyRoutes.loginRoute);
            setState(() {
              changeButton = false;
            });
          }
        } else {
          // Obsłuż błąd HTTP
          print('Błąd HTTP: ${response.statusCode}');
          print('Treść odpowiedzi: ${response.body}');
          final responseBody = jsonDecode(response.body);
          setState(() {
            errors.add(responseBody["detail"]);
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
  }

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) => get_online(context));
  // }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        child: Column(children: [
          Image.asset(
            "assets/images/login.png",
            fit: BoxFit.cover,
          ),
          Text(
            "Reset password",
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
                Form(
                    key: _formKey2,
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: "Enter email",
                        labelText: "email",
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return "email cannot be empty";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      },
                    )),
                Form(
                    key: _formKey,
                    child: Column(children: [
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: "Enter verification code",
                                  labelText: "verification code",
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return "This can't be empty";
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    verification_code = value;
                                  });
                                },
                              ),
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  send_verification_code(context);
                                },
                                child: Text("send code"))
                          ],
                        ),
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
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Re-enter password",
                          labelText: "password",
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return "Password cannot be empty";
                          }
                          if (value != password) {
                            return "Password do no match";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          password2 = value;
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
                                  "Reset",
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
                    ])),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
