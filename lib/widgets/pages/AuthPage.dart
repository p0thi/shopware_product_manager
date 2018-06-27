import 'package:diKapo/util/Util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  Function _authenticated;

  @override
  _AuthPageState createState() => new _AuthPageState();

  AuthPage(Function authenticated()) {
    _authenticated = authenticated;
  }
}

class _AuthPageState extends State<AuthPage> {
  TextEditingController usernameController =
      new TextEditingController(text: "");
  TextEditingController passController = new TextEditingController(text: "");
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        child: Padding(
          padding: EdgeInsets.all(Util.relWidth(context, 5.0)),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(Util.relWidth(context, 3.0)),
                child: Image.asset("assets/Logo - 11.01.18.png"),
              ),
              Padding(
                padding: EdgeInsets.all(Util.relWidth(context, 3.0)),
                child: new TextField(
                  controller: usernameController,
                  autofocus: true,
                  decoration: new InputDecoration(hintText: "Benutzername"),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(Util.relWidth(context, 3.0)),
                child: new TextField(
                  controller: passController,
                  obscureText: true,
                  decoration: new InputDecoration(hintText: "API Schlüssel"),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(Util.relWidth(context, 3.0)),
                child: new RaisedButton(
                  onPressed: () async {
                    bool isAuthenticated = await Util.checkCredentials(
                        usernameController.text, passController.text);
                    if (!isAuthenticated) {
                      // TODO
                      return;
                    }
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString("username", usernameController.text);
                    prefs.setString("pass", passController.text);
                    widget._authenticated != null
                        ? widget._authenticated()
                        : print("No callback set!");
                  },
                  child: new Text("Anmelden"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
