import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:good_hobbits/login_page.dart';

class MyAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;
  Widget title;
  FirebaseAuth auth = FirebaseAuth.instance;

  MyAppBar({Key key, this.title})
      : preferredSize = Size.fromHeight(50.0),
        super(key: key);

  void logout() {
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(title: title, actions: [
      IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            logout();
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()));
          })
    ]);
  }
}
