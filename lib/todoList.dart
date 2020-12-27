import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:good_hobbits/todo_view.dart';

import 'add_todo.dart';

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class Todo {
  String title;
  String count;

  Todo(this.title, this.count);
}

class _TodoListState extends State<TodoList> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  CollectionReference todoCollection;

  @override
  void initState() {
    super.initState();
    todoCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser.uid)
        .collection('todos');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: new FloatingActionButton(
        onPressed: addTodo,
        child: Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
          title: Column(
        children: [
          Text('Todo List'),
        ],
      )),
      body: Container(
        child: filteredList(),
      ),
    );
  }

  Widget filteredList() {
    return StreamBuilder<QuerySnapshot>(
        stream: todoCollection.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return ListView(
              children: snapshot.data.docs
                  .map((QueryDocumentSnapshot e) => StreamBuilder<QuerySnapshot>(
                      stream: e.reference.collection('entries').snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        return ListTile(
                            title: FlatButton(
                              child: Text(e.id),
                              onPressed: () => openHobbit(
                                  e.id,
                                  snapshot.data.docs.map((entry) {
                                    Timestamp ts = entry['date'];
                                    return DateTime.fromMillisecondsSinceEpoch(
                                        ts.millisecondsSinceEpoch);
                                  }).toList(),
                                  e.data().containsKey('labels')?e['labels']:[''],
                                  snapshot.data.docs.map((entry) =>
                                    entry.data().containsKey('comment')?entry['comment'].toString():''
                                  ).toList()
                              ),
                            ),
                            trailing: snapshot.hasError
                                ? Text('Something went wrong')
                                : snapshot.connectionState ==
                                        ConnectionState.waiting
                                    ? CircularProgressIndicator()
                                    : Text(
                                        snapshot.data.docs.length.toString()));
                      }))
                  .toList());
        });
  }

  void openHobbit(String title, List<DateTime> entries, List<String> labels, List<String> comments) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TodoView(title, entries, labels, comments)
    )
    );
  }

  void addTodo() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AddTodo()));
  }
}
