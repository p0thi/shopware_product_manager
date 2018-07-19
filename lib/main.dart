import 'dart:async';

import 'package:diKapo/util/Util.dart';
import 'package:diKapo/widgets/pages/AuthPage.dart';
import 'package:diKapo/widgets/pages/MyHomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
//  SharedPreferences.setMockInitialValues({});
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
//        const Locale('en', 'US'),
        const Locale('de', 'DE'),
      ],
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
    updateScreen();
  }

  Future updateScreen() async {
    final prefs = await SharedPreferences.getInstance();
    String username = prefs.getString("username") ?? null;
    String pass = prefs.get("pass") ?? null;
    bool isAuthenticated = await Util.checkCredentials(
        prefs.getString("username"), prefs.getString("pass"));

    setState(() {
      if (username == null || pass == null || !isAuthenticated) {
        _screen = new AuthPage(() {
          setState(() {
            updateScreen();
          });
        });
        return;
      }
      _screen = new MyHomePage(title: "diKapo App - für Mama ♥");
    });
  }
}
