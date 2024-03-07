import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:echo/utils/routes.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/myGlobals.dart' as globals;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyDrawer extends StatefulWidget {
  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String name = globals.name;
  String username = globals.username;
  String email = globals.email;
  String profile_url = globals.profile_pic;

  final server_ip = globals.server_ip;

  Logout_funt(BuildContext context) async {
    Map data = {"token": globals.token};
    //encode Map to JSON
    var body = json.encode(data);
    // var response = await http.post(
    //   Uri.parse(
    //       server_ip + '/logout'), // Tutaj przekształcamy ciąg znaków na Uri
    //   headers: {"Content-Type": "application/json"},
    //   body: body,
    // );
    await globals.storage.delete(key: 'token');
    Navigator.pushNamed(context, MyRoutes.loginRoute);
  }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) => GetData(context));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.deepPurple,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                DrawerHeader(
                  padding: EdgeInsets.zero,
                  child: UserAccountsDrawerHeader(
                    margin: EdgeInsets.zero,
                    accountName: Text(name),
                    accountEmail: Text(username),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: NetworkImage(profile_url),
                      radius: 50,
                      backgroundColor: Colors.white,
                    ),
                    decoration: BoxDecoration(color: Colors.deepPurple),
                  ),
                ),
                ListTile(
                  leading: Icon(CupertinoIcons.home),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      MyRoutes.homeRoute,
                      (route) => false,
                    );
                  },
                  title: Text(
                    "Home",
                    textScaleFactor: 1.2,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ListTile(
                  leading: Icon(CupertinoIcons.profile_circled),
                  onTap: () =>
                      Navigator.pushNamed(context, MyRoutes.profileRoute),
                  title: Text(
                    "Profile",
                    textScaleFactor: 1.2,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            Padding(
                padding: EdgeInsets.only(bottom: 20), // Dodałem Padding od dołu
                child: Column(children: [
                  ListTile(
                    leading: Icon(CupertinoIcons.settings),
                    onTap: () =>
                        Navigator.pushNamed(context, MyRoutes.SettingsRoute),
                    title: Text(
                      "Settings",
                      textScaleFactor: 1.2,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ListTile(
                    leading: Icon(CupertinoIcons.lock),
                    onTap: () => Logout_funt(context),
                    title: Text(
                      "Log out",
                      textScaleFactor: 1.2,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ])),
          ],
        ),
      ),
    );
  }
}
