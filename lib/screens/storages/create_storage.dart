import 'dart:ffi';

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

class CreateStoragesPage extends StatefulWidget {
  @override
  State<CreateStoragesPage> createState() => _CreateStoragesPageState();
}

class _CreateStoragesPageState extends State<CreateStoragesPage> {
  String atoken = globals.token;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String username = globals.username;
  bool changeButton = false;
  final _formKey = GlobalKey<FormState>();

  String name = "";
  String description = "";
  double minValue = 0;
  double maxValue = 5;
  double _selectedValue = 5;

  final server_ip = globals.server_ip;

  GetData(BuildContext context) async {
    if (globals.account_type == "owner" || globals.account_type == "admin") {
      setState(() {
        maxValue = 120;
      });
    } else {
      print(globals.account_type);
    }
  }

  create_storage(BuildContext context, String name, String description) async {
    if (_formKey.currentState?.validate() == true) {
      Map data = {
        'token': globals.token,
        'name': name,
        'descr': description,
        "size": _selectedValue,
      };
      var body = json.encode(data);
      var response = await http.post(
          Uri.parse(server_ip +
              '/storage/create_storage'), // Tutaj przekształcamy ciąg znaków na Uri
          headers: {"Content-Type": "application/json"},
          body: body);

      if (response.statusCode == 200) {
        final hej = utf8.decode(response.bodyBytes);
        final responseBody = jsonDecode(hej);
        print(responseBody);
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
        await Navigator.pushNamed(context, MyRoutes.homeRoute);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        final hej = utf8.decode(response.bodyBytes);
        final responseBody = jsonDecode(hej);
        // Obsłuż błąd HTTP
        print('Błąd HTTP: ${response.statusCode}');
        print('Treść odpowiedzi: ${response.body}');
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => GetData(context));
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
                child: "Create new storage".text.xl5.make(),
              ),
              SizedBox(height: 16),
              // Dodaj odstęp między "Profile app" a innymi segmentami
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: "Enter name",
                                  labelText: "name",
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return "This cannot be empty";
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    name = value;
                                  });
                                },
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: "Enter description",
                                  labelText: "description",
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return "This cannot be empty";
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    description = value;
                                  });
                                },
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 12,
                      ),
                      Text("Select size of storage"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Slider(
                                value: _selectedValue,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedValue = newValue;
                                  });
                                },
                                min: minValue,
                                max: maxValue,
                                divisions: null,
                                label: _selectedValue.toStringAsFixed(2)),
                          ),
                          Text("${_selectedValue.toStringAsFixed(2)} GB"),
                        ],
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      InkWell(
                        onTap: () {
                          create_storage(context, name, description);
                        },
                        child: Container(
                          height: 50,
                          width: 100,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.cyan.shade600,
                              border: Border.all(color: Colors.purple.shade600),
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            "Create",
                            style: TextStyle(color: Colors.purple.shade800),
                          ),
                        ),
                      )
                    ],
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
