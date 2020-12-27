import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTodo extends StatefulWidget {
  @override
  _AddTodoState createState() => _AddTodoState();
}

enum AddingTodo { LOADING, FAILED, SUCCESS }

class _AddTodoState extends State<AddTodo> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController todoController = new TextEditingController();
  CollectionReference todoCollection;
  AddingTodo success = AddingTodo.SUCCESS;
  var query = (DocumentSnapshot ds) => ds.id.contains('');
  String text= '';
  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    todoController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    todoCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser.uid)
        .collection('todos');
    todoController.addListener(updateQuery);
  }

  void updateQuery() {
    setState(() {
      text=todoController.text;
      query = (DocumentSnapshot ds) => ds.id.contains(todoController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(controller: todoController),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RaisedButton(
                    onPressed: success == AddingTodo.LOADING ? null : addTodo,
                    child: success == AddingTodo.LOADING
                        ? CircularProgressIndicator()
                        : Text('Add Hobbit')),
              ],
            ),
            StreamBuilder(
                stream: todoCollection.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (text=='') {
                    return Text('Please type in title');
                  } else {
                    return Expanded(
                      child: ListView(
                        children: snapshot.data.docs
                            .where(query)
                            .map((e) => ListTile(
                                  title: FlatButton(
                                    onPressed: ()=>todoController.text=e.id,
                                    child: Text(e.id),
                                  ),
                                ))
                            .toList(),
                      ),
                    );
                  }
                })
          ],
        ),
      ),
    );
  }

  addTodo() {
    setState(() {
      success = AddingTodo.LOADING;
    });
    this
        .todoCollection
        .doc(todoController.text)
        .set({'title': todoController.text}).then((e) {
      this
          .todoCollection
          .doc(todoController.text)
          .collection('entries')
          .add({'date': DateTime.now()}).then((value) {
        setState(() {
          success = AddingTodo.SUCCESS;
        });
        Navigator.of(context).pop();
      }).catchError((error) {
        setState(() {
          success = AddingTodo.FAILED;
        });
      });
    });
  }
}
