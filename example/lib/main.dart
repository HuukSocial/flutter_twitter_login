import 'package:flutter/material.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

const consumerKey = 'bxsKJAuE7fa5Q4ExCE00QzPMe';
const consumerSecret = 'UGXit0vDa21kpZd4ZyuZ1sH7XT5p5nescXYbihhViB4NjfILa2';

class _MyAppState extends State<MyApp> {
  static final TwitterLogin twitterLogin = new TwitterLogin(
    consumerKey: consumerKey,
    consumerSecret: consumerSecret,
  );

  String _message = 'Logged out.';

  void _login() async {
    final TwitterLoginResult result = await twitterLogin.authorize();

    setState(() {
      switch (result.status) {
        case TwitterLoginStatus.loggedIn:
          _message = 'Logged in! username: ${result.session!.username}';
          break;
        case TwitterLoginStatus.cancelledByUser:
          _message = 'Login cancelled by user.';
          break;
        case TwitterLoginStatus.error:
          _message = 'Login error: ${result.errorMessage}';
          break;
      }
    });
  }

  void _logout() async {
    await twitterLogin.logOut();

    setState(() {
      _message = 'Logged out.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Twitter login sample'),
        ),
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(_message),
              new ElevatedButton(
                child: new Text('Log in'),
                onPressed: _login,
              ),
              new ElevatedButton(
                child: new Text('Log out'),
                onPressed: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
