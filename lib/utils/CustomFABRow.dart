import 'package:flutter/material.dart';
import 'package:echo/utils/routes.dart';
import 'package:velocity_x/velocity_x.dart';
import '../utils/myGlobals.dart' as globals;
import '../widgets/themes.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CustomFABRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.deepPurple[300],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  MyRoutes.homeRoute,
                  (route) => false,
                );
              },
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              child: Builder(
                builder: (context) => FloatingActionButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Icon(Icons.menu),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.voice_chat),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  MyRoutes.FridayChat,
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
