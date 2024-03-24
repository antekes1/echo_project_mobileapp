import 'package:echo/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;
import '../../utils/myGlobals.dart' as globals;

class NonetPage extends StatefulWidget {
  @override
  State<NonetPage> createState() => _NonetPageState();
}

class _NonetPageState extends State<NonetPage> {
  String name = "";
  String password = "";
  String message = "";
  final server_ip = globals.server_ip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.teal[700],
        body: SafeArea(
          child: Container(
            padding: Vx.m32,
            child: Column(children: [
              Image.asset(
                "assets/images/no_net.png",
                fit: BoxFit.cover,
              ),
              SizedBox(height: 46),
              Text("No connection found !!!")
                  .text
                  .xl5
                  .bold
                  .color(Colors.blueGrey[100])
                  .make(),
              Text("Try turn on mobile data").text.xl2.make(),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => {},
                child: Text("reload"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              )
            ]),
          ),
        ));
  }
}
