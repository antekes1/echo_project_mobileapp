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

class FridayChatPage extends StatefulWidget {
  @override
  State<FridayChatPage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<FridayChatPage> {
  String atoken = globals.token;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final server_ip = globals.server_ip;
  List fridayResponses = [];
  List userInputs = [];

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) => GetData(context));
  // }

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
                child: "Friday".text.xl5.bold.make(),
              ),
              SizedBox(
                  height:
                      16), // Dodaj odstęp między "Profile app" a innymi segmentami
              Align(
                alignment: Alignment.center,
                child: "Beta ai chat. Current in development mode.".text.make(),
              ),
              Container(
                  height: 450,
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [],
                    ),
                  )),
              Container(
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [],
                  ))
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
