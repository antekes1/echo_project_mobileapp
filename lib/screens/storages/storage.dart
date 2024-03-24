import 'dart:ffi';

import 'package:echo/screens/storages/storage_settings.dart';
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

class StoragePage extends StatefulWidget {
  final int storageId;

  // StoragePage({required this.storageId});
  StoragePage({Key? key, required this.storageId}) : super(key: key);

  @override
  State<StoragePage> createState() => _CreateStoragesPageState();
}

class _CreateStoragesPageState extends State<StoragePage> {
  String atoken = globals.token;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String username = globals.username;
  bool changeButton = false;
  bool isClicked = false;

  String name_storage = "";
  int max_size = 0;
  int actual_size = 0;
  String owner_name = "";

  final server_ip = globals.server_ip;

  Get_data(BuildContext context) async {
    Map data = {'token': globals.token, 'storage_id': widget.storageId};
    var body = json.encode(data);
    var response = await http.post(
        Uri.parse(server_ip +
            '/storage/info'), // Tutaj przekształcamy ciąg znaków na Uri
        headers: {"Content-Type": "application/json"},
        body: body);

    if (response.statusCode == 200) {
      // Odpowiedź jest poprawna
      final responseBody = jsonDecode(response.body);
      // Zalogowano pomyślnie
      setState(() {
        name_storage = responseBody['name'];
        max_size = responseBody['max_size'];
        actual_size = responseBody['actual_size'];
        owner_name = responseBody['owner_username'];
      });
    } else {
      // Obsłuż błąd HTTP
      print('Błąd HTTP: ${response.statusCode}');
      print('Treść odpowiedzi: ${response.body}');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => Get_data(context));
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
              GestureDetector(
                onTap: () {
                  setState(() {
                    isClicked = !isClicked;
                  });
                  Future.delayed(Duration(milliseconds: 10), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StorageSettingsPage(storageId: widget.storageId),
                      ),
                    );
                  });
                },
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // Ustawienie wyrównania do lewej
                    children: [
                      "${name_storage} storage:"
                          .text
                          .xl2
                          .make(), // Zmiana: Dodanie dwukropka po nazwie
                      Text("${actual_size / 1000}GB of ${max_size}GB"),
                    ],
                  ),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(17)),
                    border: Border.all(
                        color: isClicked
                            ? Colors.deepPurple.shade700
                            : Colors.grey),
                  ),
                  padding: EdgeInsets.all(9),
                ),
              ),
              SizedBox(height: 16),
              Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Container(
                      child: Text("path"),
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.deepPurpleAccent.shade700)),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      alignment: Alignment.centerLeft,
                      child: Column(),
                    )
                  ],
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
