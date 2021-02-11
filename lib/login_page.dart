import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:good_hobbits/todoList.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController emailController;
  TextEditingController passwordController;
  bool showPass = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    emailController = new TextEditingController();
    passwordController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: showPass,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),
                    ),
                    IconButton(
                        icon: Icon(showPass
                            ? Icons.remove_red_eye
                            : Icons.remove_red_eye_outlined),
                        onPressed: toggleObscureText)
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    onPressed: logIn,
                    child: Text("Skip"),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          onPressed: register,
                          child: Text("Register"),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          onPressed: emailLogin,
                          child: Text("Login"),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  void logIn() {
    auth.signInAnonymously();

    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => TodoList()));
  }

  void emailLogin() {
    auth.signInWithEmailAndPassword(
        email: emailController.text, password: passwordController.text).then(
        (result){
          if(result!=null){
            Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (context) => TodoList()));
          }

        }
    );


  }

  void register() {
    auth.createUserWithEmailAndPassword(
        email: emailController.text, password: passwordController.text);
  }

  void toggleObscureText() {
    setState(() {
      showPass = !showPass;
    });
  }
}
