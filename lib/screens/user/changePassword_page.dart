import 'package:echo/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../utils/myGlobals.dart' as globals;
import 'package:flutter/cupertino.dart';
import 'package:echo/utils/routes.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/CustomFABRow.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  State<ChangePasswordPage> createState() => _CreateStoragesPageState();
}

class _CreateStoragesPageState extends State<ChangePasswordPage> {
  String atoken = globals.token;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String username = globals.username;
  bool changeButton = false;

  final server_ip = globals.server_ip;
  String old_pass = "";
  String new_pass1 = "";
  String new_pass2 = "";

  change_pass(BuildContext context) async {
    if (_formKey.currentState?.validate() == true) {
      Map data = {
        'token': globals.token,
        'old_password': old_pass,
        'new_password': new_pass1,
      };
      var body = json.encode(data);
      var response = await http.post(
          Uri.parse(server_ip +
              '/auth/change_password'), // Tutaj przekształcamy ciąg znaków na Uri
          headers: {"Content-Type": "application/json"},
          body: body);

      if (response.statusCode == 200) {
        // Odpowiedź jest poprawna
        final hej = utf8.decode(response.bodyBytes);
        final responseBody = jsonDecode(hej);
        final snackBar = SnackBar(
          content: Text(
            responseBody["msg"],
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
      } else {
        // Obsłuż błąd HTTP
        print('Błąd HTTP: ${response.statusCode}');
        print('Treść odpowiedzi: ${response.body}');
        final hej = utf8.decode(response.bodyBytes);
        final responseBody = jsonDecode(hej);
        final snackBar = SnackBar(
          content: Text(
            responseBody["detail"],
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Container(
          padding: Vx.m32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: "Change password".text.xl5.make(),
              ),
              SizedBox(height: 16),
              // Dodaj odstęp między "Profile app" a innymi segmentami
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: Colors.purple.shade700)),
                          padding: EdgeInsets.all(12),
                          child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    decoration: InputDecoration(
                                      hintText: "Enter old password",
                                      labelText: "old password",
                                    ),
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return "This cannot be empty";
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        old_pass = value;
                                      });
                                    },
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      hintText: "Enter new password",
                                      labelText: "new password",
                                    ),
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return "This cannot be empty";
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        new_pass1 = value;
                                      });
                                    },
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      hintText: "Confirm password",
                                      labelText: "new passowrd",
                                    ),
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return "This cannot be empty";
                                      }
                                      if (value != new_pass1) {
                                        return "Password do not match";
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        new_pass2 = value;
                                      });
                                    },
                                  ),
                                ],
                              )),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        InkWell(
                          onTap: () {
                            change_pass(context);
                          },
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 40, 1, 77),
                                border: Border.all(
                                    color: Color.fromARGB(255, 238, 11, 208)),
                                borderRadius: BorderRadius.circular(16)),
                            child: Text(
                              "Change",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 238, 11, 208)),
                            ),
                          ),
                        )
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
      drawer: MyDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Builder(
        builder: (context) => CustomFABRow(),
      ),
    );
  }
}
