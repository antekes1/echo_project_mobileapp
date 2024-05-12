import 'package:echo/screens/storages/storage.dart';
import 'package:echo/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:echo/utils/routes.dart';
import '../utils/myGlobals.dart' as globals;
import '../widgets/themes.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/CustomFABRow.dart';
import '../widgets/entry_point.dart';
import '../utils/custom_funtions.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String atoken = globals.token;
  final server_ip = globals.server_ip;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> listaObiektow = [];

  GetData(BuildContext context) async {
    var response = await http.get(
      Uri.parse(server_ip +
          '/storage/' +
          globals.token), // Tutaj przekształcamy ciąg znaków na Uri
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      // Odpowiedź jest poprawna
      final hej = utf8.decode(response.bodyBytes);
      final responseBody = jsonDecode(hej);

      if (responseBody.containsKey('storages')) {
        // Zalogowano pomyślnie
        setState(() {
          listaObiektow = responseBody['storages'];
        });
      }
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
    get_online(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Container(
          child: Column(children: [
            "Echo app".text.xl5.bold.make(),
            Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    child: Icon(Icons.add_circle_outline_rounded),
                    onTap: () {
                      Navigator.pushNamed(context, MyRoutes.createStorage);
                    },
                  ),
                ),
                if (listaObiektow.length != 0)
                  Container(
                    // color: Colors.amber,
                    constraints: const BoxConstraints.expand(height: 170),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: listaObiektow.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StoragePage(
                                    storageId: listaObiektow[index][0]),
                              ),
                            );
                          },
                          child: Container(
                            width:
                                250, // Szerokość każdego elementu w poziomej liście
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(16)),
                            child: Center(
                              child: Text(
                                listaObiektow[index][1],
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    alignment: Alignment.center,
                    height: 170,
                    child: Text(
                      "No storages available",
                      style: TextStyle(fontSize: 22),
                    ).centered(),
                  ),
              ],
            ),
          ]),
        ),
      ),

      // drawer: MyDrawer(),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: Builder(
      //   builder: (context) => FloatingActionButton(
      //     onPressed: () {
      //       Scaffold.of(context).openDrawer();
      //     },
      //     child: Icon(Icons.menu),
      //   ),
      // ),
      drawer: MyDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Builder(
        builder: (context) => CustomFABRow(),
      ),
      // bottomNavigationBar: EntryPoint(),
    );
  }
}
