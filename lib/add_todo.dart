import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';

class AddTodo extends StatefulWidget {
  @override
  _AddTodoState createState() => _AddTodoState();
}

enum AddingTodo { LOADING, FAILED, SUCCESS }

class _AddTodoState extends State<AddTodo> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController todoController = new TextEditingController();
  TextEditingController commentController = new TextEditingController();

  CollectionReference todoCollection;
  AddingTodo success = AddingTodo.SUCCESS;
  var query = (DocumentSnapshot ds) => ds.id.contains('');
  String text = '';
  bool hasFocus;
  FocusNode titleFocusNode;

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    todoController.dispose();
    commentController.dispose();
    titleFocusNode.dispose();
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
    titleFocusNode = new FocusNode();
  }

  void updateQuery() {
    setState(() {
      text = todoController.text;
      query = (DocumentSnapshot ds) =>
          ds.id.contains(todoController.text) && ds.id != todoController.text;
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
            Container(
              margin: EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                        decoration: InputDecoration(labelText: 'Title'),
                        focusNode: titleFocusNode,
                        controller: todoController),
                  ),
                  FlatButton(
                      onPressed: () => confirmTitle(),
                      child: success == AddingTodo.LOADING
                          ? CircularProgressIndicator()
                          : Icon(Icons.check, color: Colors.green)),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    margin: EdgeInsets.all(8.0),
                    padding: EdgeInsets.only(bottom: 50),

                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines:99,
                      decoration: InputDecoration(
                        labelText: 'Comment',
                        border: OutlineInputBorder(),
                      ),
                      controller: commentController,
                    ),
                  ),
                  titleFocusNode.hasFocus
                      ? StreamBuilder(
                          stream: todoCollection.snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (text == '' || snapshot.data.docs.where(query).length < 1) {
                              return Container();
                            } else {
                              return Container(
                                color: Colors.white,

                                child:
                                ListView.separated(

                                    separatorBuilder: (context, index) =>
                                        Divider(),
                                    itemCount: snapshot.data.docs.where(query).length,
                                    itemBuilder: (_, index) {
                                      return ListTile(
                                        title: FlatButton(
                                          color: Colors.white,
                                          onPressed: () {
                                            todoController.text = snapshot.data.docs.where(query).toList()[index].id;
                                          },
                                          child: Text(snapshot.data.docs.where(query).toList()[index].id),
                                        ),
                                      );
                            }                  ),
                              );
                            }
                          })
                      : Container(),
                ],
              ),
            ),
            RaisedButton(
              onPressed:
                  this.todoController.text.length < 1 ? null : () => addTodo(),
              child: Text(
                'Add Hobbit',
                style: TextStyle(color: Colors.white),
              ),
              color: this.todoController.text.length < 1
                  ? Colors.redAccent
                  : Colors.green,
            )
          ],
        ),
      ),
    );
  }

  confirmTitle() {
    this.titleFocusNode.unfocus();
  }

  addTodo() {
    setState(() {
      success = AddingTodo.LOADING;
    });
    this
        .todoCollection
        .doc(todoController.text)
        .set({'title': todoController.text}).then((e) {
      this.todoCollection.doc(todoController.text).collection('entries').add({
        'date': DateTime.now(),
        'comment': this.commentController.text.length>0?this.commentController.text:''
      }).then((value) {
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
