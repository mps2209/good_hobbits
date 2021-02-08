import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:good_hobbits/todo_view.dart';
import 'package:good_hobbits/util/MyAppBar.dart';

import 'add_todo.dart';
import 'model/hobbit_model.dart';

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
      appBar: MyAppBar(
          title: Column(
        children: [
          Text('Todo List'),
        ],
      )),
      body: Container(
        child: todoList(),
      ),
    );
  }

  Widget todoList() {
    return StreamBuilder<QuerySnapshot>(
        stream: todoCollection.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data == null) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasData) {
            return buildList(
                snapshot.data.docs.map((e) => Hobbit.fromSnapshot(e)).toList());
          }
          return CircularProgressIndicator();
        });
  }

  Widget buildList(List<Hobbit> hobbits) {
    return ListView(
        children: hobbits
            .map((Hobbit hobbit) => ListTile(
                title: FlatButton(
                  child: Text(hobbit.title),
                  onPressed: () => openHobbit(hobbit),
                ),
                trailing: FutureBuilder(
                    future: hobbit.entries,
                    builder:
                        (context, AsyncSnapshot<List<HobbitEntry>> snapshot) {
                      if (snapshot.hasData) {
                        return Text(snapshot.data.length.toString());
                      } else if (snapshot.hasError) {
                        return Container(child: Icon(Icons.error));
                      } else {
                        return CircularProgressIndicator();
                      }
                    })))
            .toList());
  }

  void openHobbit(Hobbit hobbit) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => TodoView(hobbit)));
  }

  void addTodo() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AddTodo()));
  }
}
