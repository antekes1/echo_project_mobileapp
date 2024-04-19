import 'package:echo/screens/friday_chat.dart';
import 'package:echo/screens/login_page.dart';
import 'package:echo/screens/error_screens/no_net.dart';
import 'package:echo/screens/profile_page.dart';
import 'package:echo/screens/settings.dart';
import 'package:echo/screens/user/updateUser.dart';
import 'package:echo/screens/user/changePassword_page.dart';
import 'package:echo/screens/storages/create_storage.dart';
import 'package:echo/screens/storages/storage.dart';
import 'package:echo/screens/storages/storage_settings.dart';
import 'package:echo/widgets/entry_screen.dart';
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
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final server_ip = globals.server_ip;

  @override
  Widget build(BuildContext context) {
    // get_online(context);
    return MaterialApp(
      locale: const Locale('pl', 'PL'),
      themeMode: ThemeMode.dark,
      theme: MyTheme.lightTheme(context),
      debugShowCheckedModeBanner: false,
      darkTheme: MyTheme.darkTheme(context),
      initialRoute: "/",
      routes: {
        "/": (context) => Entry_screen(),
        MyRoutes.homeRoute: (context) => HomePage(),
        MyRoutes.loginRoute: (context) => LoginPage(),
        MyRoutes.profileRoute: (context) => ProfilePage(),
        MyRoutes.NonetRoute: (context) => NonetPage(),
        MyRoutes.SettingsRoute: (context) => SettingsPage(),
        MyRoutes.FridayChat: (context) => FridayChatPage(),
        MyRoutes.Storage: (context) => StoragePage(storageId: 0),
        MyRoutes.StorageSettings: (context) =>
            StorageSettingsPage(storageId: 0),
        MyRoutes.createStorage: (context) => CreateStoragesPage(),
        MyRoutes.UpdateUser: (context) => UpdateUserPage(),
        MyRoutes.ChangePassword: (context) => ChangePasswordPage(),
      },
    );
  }
}
