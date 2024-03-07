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

class UpdateUserPage extends StatefulWidget {
  @override
  State<UpdateUserPage> createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  String atoken = globals.token;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String username = globals.username;
  bool changeButton = false;
  bool succesfullyUpdate = false;
  final server_ip = globals.server_ip;
  String email = globals.email;
  String name = globals.name;
  String username_field = globals.username;

  TextEditingController _textController = TextEditingController(text: "test");
  late TextEditingController _emailController = TextEditingController();
  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => GetData(context));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
  // TextEditingController _usernameController =
  //     TextEditingController(text: username);
  // TextEditingController _nameController = TextEditingController(text: name);
  // TextEditingController _emailController = TextEditingController(text: email);

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
          _usernameController.text = responseBody['username'];
          _nameController.text = responseBody['name'];
          _emailController.text = responseBody['email'];
          username_field = responseBody['username'];
          name = responseBody['name'];
          email = responseBody['email'];
        });
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

  UpdateUserInfo(BuildContext context) async {
    print('test1');
    Map data = {
      'token': globals.token,
      'name': name,
      'username': username_field,
      'email': email,
    };
    //encode Map to JSON
    var body = json.encode(data);

    var response = await http.post(
        Uri.parse(server_ip +
            '/user/update'), // Tutaj przekształcamy ciąg znaków na Uri
        headers: {"Content-Type": "application/json"},
        body: body);

    if (response.statusCode == 200) {
      final responseBody =
          jsonDecode(response.body); // Parsuj treść odpowiedzi JSON
      print(responseBody);
      if (responseBody.containsKey('msg')) {
        final snackBar = SnackBar(
          content: Text(
            'Updated successfully',
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.transparent,
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
                child:
                    "Update user".text.xl5.bold.color(Colors.deepPurple).make(),
              ),
              SizedBox(height: 26),
              Container(
                alignment: Alignment.center,
                child: TextField(
                  controller: _usernameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: BorderSide(color: Colors.pink)),
                      suffixText: "username",
                      prefixIcon: Icon(Icons.alternate_email)),
                  onChanged: (value) {
                    username_field = value;
                    setState(() {});
                  },
                ),
              ),
              SizedBox(height: 10),
              Container(
                alignment: Alignment.center,
                child: TextField(
                  keyboardType: TextInputType.text,
                  controller: _nameController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: BorderSide(color: Colors.pink)),
                      suffixText: "name",
                      prefixIcon: Icon(Icons.person)),
                  onChanged: (value) {
                    name = value;
                    setState(() {});
                  },
                ),
              ),
              SizedBox(height: 10),
              Container(
                alignment: Alignment.center,
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: BorderSide(color: Colors.pink)),
                      suffixText: "email",
                      prefixIcon: Icon(Icons.email)),
                  onChanged: (value) {
                    email = value;
                    setState(() {});
                  },
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 50,
                  width: 140,
                  child: ElevatedButton(
                    onPressed: () => UpdateUserInfo(context),
                    child: Text(
                      'Update data',
                      textAlign: TextAlign.center,
                    ),
                    style: ButtonStyle(alignment: Alignment.center),
                  ),
                ),
              ),
              SizedBox(
                height: 60,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                    child: InkWell(
                  onTap: () {},
                  child: AnimatedContainer(
                    duration: Duration(seconds: 1),
                    width: 170,
                    height: 50,
                    alignment: Alignment.center,
                    child: changeButton
                        ? Icon(
                            Icons.delete,
                            color: Colors.white,
                          )
                        : Text(
                            "Change password",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.teal[400],
                    ),
                  ),
                )),
              )
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
