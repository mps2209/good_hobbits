import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:good_hobbits/todoList.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget{
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: RaisedButton(
          onPressed: logIn ,
          child: Text("Anonymous Login"),
        )
      ),
    );
  }
  void logIn(){
      auth.signInAnonymously();

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>TodoList()));
  }
}