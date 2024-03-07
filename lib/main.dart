import 'package:echo/screens/friday_chat.dart';
import 'package:echo/screens/login_page.dart';
import 'package:echo/screens/no_net.dart';
import 'package:echo/screens/profile_page.dart';
import 'package:echo/screens/settings.dart';
import 'package:echo/screens/user/updateUser.dart';
import 'package:echo/screens/storages/create_storage.dart';
import 'package:echo/utils/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:echo/utils/routes.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:echo/widgets/themes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/myGlobals.dart' as globals;

import 'screens/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final server_ip = globals.server_ip;

  @override
  Widget build(BuildContext context) {
    // get_online(context);
    return MaterialApp(
      themeMode: ThemeMode.dark,
      theme: MyTheme.lightTheme(context),
      debugShowCheckedModeBanner: false,
      darkTheme: MyTheme.darkTheme(context),
      initialRoute: "/",
      routes: {
        "/": (context) => LoginPage(),
        MyRoutes.homeRoute: (context) => HomePage(),
        MyRoutes.loginRoute: (context) => LoginPage(),
        MyRoutes.profileRoute: (context) => ProfilePage(),
        MyRoutes.NonetRoute: (context) => NonetPage(),
        MyRoutes.SettingsRoute: (context) => SettingsPage(),
        MyRoutes.FridayChat: (context) => FridayChatPage(),
        MyRoutes.createStorage: (context) => CreateStoragesPage(),
        MyRoutes.UpdateUser: (context) => UpdateUserPage(),
      },
    );
  }
}
