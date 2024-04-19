import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:echo/widgets/drawer.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../utils/myGlobals.dart' as globals;
import 'package:flutter/cupertino.dart';
import 'package:echo/utils/routes.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/CustomFABRow.dart';
import '../../utils/custom_funtions.dart';

class StorageSettingsPage extends StatefulWidget {
  final int storageId;

  // StoragePage({required this.storageId});
  StorageSettingsPage({Key? key, required this.storageId}) : super(key: key);

  @override
  State<StorageSettingsPage> createState() => _CreateStoragesPageState();
}

class _CreateStoragesPageState extends State<StorageSettingsPage> {
  String atoken = globals.token;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String username = globals.username;
  bool changeButton = false;

  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _descrController = TextEditingController();

  String name_storage = "";
  int max_size = 0;
  double actual_size = 0;
  String owner_name = "";
  String storage_description = "";
  List actual_users = [];

  List errors = [];
  String user_to_add = "";

  final server_ip = globals.server_ip;

  Get_storage_users(BuildContext context) async {
    Map data = {
      "token": globals.token,
      "storage_id": widget.storageId,
      "action": "get_current_users",
      "updated_users_usernames": [],
    };
    var body = json.encode(data);
    var response = await http.put(
        Uri.parse(server_ip +
            '/storage/users'), // Tutaj przekształcamy ciąg znaków na Uri
        headers: {"Content-Type": "application/json"},
        body: body);
    if (response.statusCode == 200) {
      // Odpowiedź jest poprawna
      final hej = utf8.decode(response.bodyBytes);
      final responseBody = jsonDecode(hej);
      // Zalogowano pomyślnie
      setState(() {
        actual_users = responseBody["current_users"];
      });
    } else {
      // Obsłuż błąd HTTP
      print('Błąd HTTP: ${response.statusCode}');
      print('Treść odpowiedzi: ${response.body}');
    }
  }

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
      final hej = utf8.decode(response.bodyBytes);
      final responseBody = jsonDecode(hej);
      // Zalogowano pomyślnie
      setState(() {
        name_storage = responseBody['name'];
        max_size = responseBody['max_size'];
        actual_size = responseBody['actual_size'];
        owner_name = responseBody['owner_username'];
        storage_description = responseBody['description'];
        _descrController.text = responseBody['description'];
        _nameController.text = responseBody['name'];
      });
      await Get_storage_users(context);
    } else {
      // Obsłuż błąd HTTP
      print('Błąd HTTP: ${response.statusCode}');
      print('Treść odpowiedzi: ${response.body}');
    }
  }

  addUsertoStorage(BuildContext context) async {
    await get_online(context);
    Map data = {
      "token": globals.token,
      "storage_id": widget.storageId,
      "action": "add_users",
      "updated_users_usernames": [user_to_add],
    };
    var body = json.encode(data);

    if (user_to_add != "") {
      var response = await http.put(
          Uri.parse(server_ip +
              '/storage/users'), // Tutaj przekształcamy ciąg znaków na Uri
          headers: {"Content-Type": "application/json"},
          body: body);
      if (response.statusCode == 200) {
        final hej = utf8.decode(response.bodyBytes);
        final responseBody = jsonDecode(hej);
        Get_storage_users(context);
        if (responseBody.containsKey('msg')) {
          if (responseBody['msg'] == 'succes') {
            final snackBar = SnackBar(
              content: Text(
                'User add successfully',
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
            final snackBar = SnackBar(
              content: Text(
                responseBody['errors'][0],
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
    } else {
      final snackBar = SnackBar(
        content: Text(
          'no username entry',
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
      Get_storage_users(context);
    }
  }

  removeUserfromStorage(BuildContext context, String userName) async {
    await get_online(context);
    Map data = {
      "token": globals.token,
      "storage_id": widget.storageId,
      "action": "remove_users",
      "updated_users_usernames": [userName],
    };
    var body = json.encode(data);

    var response = await http.put(
        Uri.parse(server_ip +
            '/storage/users'), // Tutaj przekształcamy ciąg znaków na Uri
        headers: {"Content-Type": "application/json"},
        body: body);
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody.containsKey('msg')) {
        if (responseBody['msg'] == 'succes') {
          final snackBar = SnackBar(
            content: Text(
              'User remove successfully',
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
          await Get_storage_users(context);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        final snackBar = SnackBar(
          content: Text(
            responseBody['errors'][0],
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
        await Get_storage_users(context);
      }
    }
  }

  UpdateStorageInfo(BuildContext context) async {
    await get_online(context);
    print(name_storage);
    print(storage_description);
    Map data = {
      'token': globals.token,
      'storage_id': widget.storageId,
      'name': name_storage,
      "descr": storage_description,
    };
    var body = json.encode(data);
    var response = await http.put(Uri.parse(server_ip + '/storage/update'),
        headers: {"Content-Type": "application/json"}, body: body);
    if (response.statusCode == 200) {
      // Odpowiedź jest poprawna
      final hej = utf8.decode(response.bodyBytes);
      final responseBody = jsonDecode(hej);
      if (responseBody.containsKey('msg')) {
        final snackBar = SnackBar(
          content: Text(
            'Updated succesfull',
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
        final snackBar = SnackBar(
          content: Text(
            responseBody['detail'],
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
      final responseBody = jsonDecode(response.body);
      final snackBar = SnackBar(
        content: Text(
          responseBody['detail'],
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

  deleteStorage(BuildContext context) async {
    await get_online(context);
    Map data = {
      "token": globals.token,
      "storage_id": widget.storageId,
    };
    var body = json.encode(data);
    var response = await http.post(
        Uri.parse(server_ip +
            '/storage/delete_storage'), // Tutaj przekształcamy ciąg znaków na Uri
        headers: {"Content-Type": "application/json"},
        body: body);

    if (response.statusCode == 200) {
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
      await Navigator.pushNamed(context, MyRoutes.homeRoute);
    } else {
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => Get_data(context));
  }

  @override
  void dispose() {
    _descrController.dispose();
    _nameController.dispose();
    super.dispose();
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .start, // Ustawienie wyrównania do lewej
                  children: [
                    "${name_storage} storage:"
                        .text
                        .xl2
                        .make(), // Zmiana: Dodanie dwukropka po nazwie
                    Text(
                        "${(actual_size / 1073741824).toStringAsFixed(2)}GB of ${max_size}GB"),
                  ],
                ),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(17)),
                  border: Border.all(color: Colors.grey),
                ),
                padding: EdgeInsets.all(9),
              ),
              SizedBox(height: 5),
              Center(
                  child: "Storage Settings: "
                      .text
                      .bold
                      .xl3
                      .color(Colors.deepPurple.shade300)
                      .make()),
              SizedBox(height: 16),
              Container(
                height: MediaQuery.of(context).size.height * 0.64,
                child: ListView(scrollDirection: Axis.vertical, children: [
                  "Add or delete users to your storage: ".text.makeCentered(),
                  Container(
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                                child: Container(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Enter username to add',
                                  labelText: "username",
                                  contentPadding: EdgeInsets.all(10.0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.pink),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    user_to_add = value;
                                  });
                                },
                              ),
                            )),
                            SizedBox(width: 5.0),
                            ElevatedButton(
                              onPressed: () {
                                addUsertoStorage(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent.shade200,
                                padding: EdgeInsets.all(10.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Submit',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(height: 1),
                  Container(
                    alignment: Alignment.center,
                    child: Column(children: [
                      Container(
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: actual_users.length,
                            itemBuilder: (context, index) {
                              return Container(
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(actual_users[index]),
                                            InkWell(
                                                onTap: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                            title: Text(
                                                                "Delete user"),
                                                            content: Text(
                                                                "Deleting user form storage. User will not have acces to this storage"),
                                                            actions: [
                                                              TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  await removeUserfromStorage(
                                                                      context,
                                                                      actual_users[
                                                                          index]);
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                    Text('ok'),
                                                              ),
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context),
                                                                child: Text(
                                                                    "cancle"),
                                                              ),
                                                            ],
                                                          ));
                                                },
                                                child:
                                                    Icon(Icons.delete_forever))
                                          ],
                                        ),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: Color.fromARGB(
                                                    99, 156, 217, 1000))),
                                      ),
                                    )
                                  ],
                                ),
                                margin: EdgeInsets.all(6),
                              );
                            }),
                        height: 250,
                      ),
                    ]),
                  ),
                  "Set name and description".text.makeCentered(),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(9),
                    child: Column(
                      children: [
                        Container(
                          height: 50,
                          alignment: Alignment.center,
                          child: TextField(
                            controller: _nameController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: BorderSide(color: Colors.pink)),
                                suffixText: "name",
                                labelText: "name",
                                prefixIcon: Icon(Icons.apps_rounded)),
                            onChanged: (value) {
                              setState(() {
                                name_storage = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Container(
                          height: 50,
                          alignment: Alignment.center,
                          child: TextField(
                            controller: _descrController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: BorderSide(color: Colors.pink)),
                                suffixText: "description",
                                labelText: "description",
                                prefixIcon: Icon(Icons.abc_outlined)),
                            onChanged: (value) {
                              setState(() {
                                storage_description = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              UpdateStorageInfo(context);
                            },
                            child: Text("Update")),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text("Delete storage"),
                                content: Text(
                                    "Deleting storage, after performing this action, the data will be lost. Do you want to continue ?"),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      await deleteStorage(context);
                                      Navigator.pop(context);
                                    },
                                    child: Text('ok'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("cancle"),
                                  ),
                                ],
                              ));
                    },
                    child: Container(
                      height: 50,
                      width: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.purple.shade300)),
                      child: Text(
                        "Delete this storage",
                        style: TextStyle(),
                      ),
                    ),
                  ),
                ]),
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
