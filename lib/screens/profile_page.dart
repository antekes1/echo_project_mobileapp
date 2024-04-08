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

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String atoken = globals.token;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String name = "";
  String username = "";
  String email = "";
  String profile_url = "";
  final server_ip = globals.server_ip;

  GetData(BuildContext context) async {
    Map data = {
      'token': globals.token,
      'field': ['name', 'login', 'email']
    };
    //encode Map to JSON
    var body = json.encode(data);

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
          username = responseBody['username'];
          name = responseBody['name'];
          email = responseBody['email'];
          profile_url = server_ip + "/photo/" + responseBody['profile_pic'];
          globals.username = responseBody['username'];
          globals.name = responseBody['name'];
          globals.email = responseBody['email'];
          globals.account_type = responseBody['account_type'];
          globals.profile_pic =
              server_ip + "/photo/" + responseBody['profile_pic'];
        });
        print(profile_url);
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => GetData(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      // appBar: AppBar(ProfilePagenThemeData(color: Colors.purple[400]),
      // ),
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
                child: "Profile app".text.xl5.bold.make(),
              ),
              SizedBox(
                  height:
                      16), // Dodaj odstęp między "Profile app" a innymi segmentami
              Align(
                alignment: Alignment.center,
                child: "Name: $name".text.make(),
              ),
              Align(
                alignment: Alignment.center,
                child: "Username: $username".text.make(),
              ),
              Align(
                alignment: Alignment.center,
                child: "Email: $email".text.make(),
              ),
              SizedBox(height: 10),
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
