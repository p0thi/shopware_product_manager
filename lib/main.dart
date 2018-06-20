import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/util/AppRouter.dart';
import 'package:flutter_app/widgets/pages/AuthPage.dart';
import 'package:flutter_app/widgets/pages/MyHomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
//  SharedPreferences.setMockInitialValues({});
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  MyApp();

  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _screen;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'diKapo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.green,
      ),
      home: _screen == null
          ? new Container(
              color: Colors.white,
              child: new Center(
                child: new CircularProgressIndicator(),
              ),
            )
          : _screen,
    );
  }

  @override
  void initState() {
    super.initState();
    final appRouter = new AppRouter();
    appRouter.configureRoutes();
//    appRouter.router().printTree();
    updateScreen();
  }

  Future updateScreen() async {
    final prefs = await SharedPreferences.getInstance();
    String username = prefs.getString("username") ?? null;
    String pass = prefs.get("pass") ?? null;

    setState(() {
      if (username == null || pass == null) {
        _screen = new AuthPage(() {
          setState(() {
            updateScreen();
          });
        });
        return;
      }
      _screen = new MyHomePage(title: 'diKapo Mützen Verwaltungs App');
    });
  }
}
