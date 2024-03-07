import 'package:echo/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '../utils/myGlobals.dart' as globals;
import 'package:flutter/cupertino.dart';
import 'package:echo/utils/routes.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/CustomFABRow.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String atoken = globals.token;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String username = globals.username;
  bool changeButton = false;

  final server_ip = globals.server_ip;

  del_token(BuildContext context) async {
    var response = await http.post(
      Uri.parse(server_ip +
          '/auth/delete_token/' +
          globals.token), // Tutaj przekształcamy ciąg znaków na Uri
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      // Odpowiedź jest poprawna
      final responseBody =
          jsonDecode(response.body); // Parsuj treść odpowiedzi JSON

      if (responseBody == true) {
        // Zalogowano pomyślnie
        setState(() {
          changeButton = true;
        });
        await globals.storage.delete(key: 'token');
        Navigator.pushNamedAndRemoveUntil(
          context,
          MyRoutes.loginRoute,
          (route) => false,
        );
      }
    } else {
      // Obsłuż błąd HTTP
      print('Błąd HTTP: ${response.statusCode}');
      print('Treść odpowiedzi: ${response.body}');
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) => GetData(context));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Container(
          padding: Vx.m32,
          // child: Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Container(
          //       child: "Profile app".text.xl5.bold.make(),
          //     ),
          //     Container(
          //       child: "Name: $name".text.make(),
          //       "Username: $username".text.make(),
          //       "Email: $email".text.make(),
          //     ),
          //   ],
          // ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: "Settings".text.xl5.bold.make(),
              ),
              SizedBox(height: 16),
              // Dodaj odstęp między "Profile app" a innymi segmentami
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Align(
                  alignment: Alignment.center,
                  child: "Username: $username".text.xl2.make(),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: "Change user info and password".text.xl.make(),
              ),
              Padding(padding: EdgeInsets.only(bottom: 20)),
              Container(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 50.0,
                  width: 150.0,
                  child: ElevatedButton(
                    child: "Update info".text.base.xl.make(),
                    onPressed: () {
                      Navigator.pushNamed(context, MyRoutes.UpdateUser);
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20),
              ),
              Container(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () => {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text("Log out"),
                              content: Text(
                                  "Log out from all drivers. You must log in again on all drivers"),
                              actions: [
                                TextButton(
                                  onPressed: () => del_token(context),
                                  child: Text('ok'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("cancle"),
                                ),
                              ],
                            ))
                  },
                  child: AnimatedContainer(
                    duration: Duration(seconds: 1),
                    width: 150,
                    height: 50,
                    alignment: Alignment.center,
                    child: changeButton
                        ? Icon(
                            Icons.delete,
                            color: Colors.white,
                          )
                        : Text(
                            "Log out",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.teal[400],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: "Log out from all drivers.".text.make(),
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
