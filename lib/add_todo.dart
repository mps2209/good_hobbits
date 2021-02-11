import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:good_hobbits/util/MyAppBar.dart';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';

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
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  CollectionReference todoCollection;
  AddingTodo success = AddingTodo.SUCCESS;
  var query = (DocumentSnapshot ds) => ds.id.contains('');
  String text = '';
  bool hasFocus;
  FocusNode titleFocusNode;
  FocusNode commentFocusNode;

  File _imageFile;
  String uploadurl;
  bool isUploading = false;
  bool typingComment = false;

  ///NOTE: Only supported on Android & iOS
  ///Needs image_picker plugin {https://pub.dev/packages/image_picker}
  final picker = ImagePicker();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    todoController.dispose();
    commentController.dispose();
    titleFocusNode.dispose();
    commentFocusNode.dispose();

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
    commentFocusNode = new FocusNode();
    commentFocusNode.addListener(focusChanged);
  }

  void focusChanged() {
    setState(() {
      this.typingComment = commentFocusNode.hasFocus;
    });
  }

  Future<void> uploadImage() async {
    String filePath = _imageFile.path;
    try {
      setState(() {
        isUploading = true;
      });
      await firebase_storage.FirebaseStorage.instance
          .ref(baseName(_imageFile.path))
          .putFile(_imageFile);
      uploadurl = baseName(_imageFile.path);
      setState(() {
        isUploading = true;
      });
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      // e.g, e.code == 'canceled'
    }
  }

  void updateQuery() {
    setState(() {
      text = todoController.text;
      query = (DocumentSnapshot ds) =>
          ds.id.contains(todoController.text) && ds.id != todoController.text;
    });
  }

  Future pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }

  String baseName(String path) {
    return auth.currentUser.uid + '/' + path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
      appBar: MyAppBar(
        title: Text('Add Hobbit'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            typingComment
                ? Container()
                : Container(
                    margin: EdgeInsets.only(left: 4, right: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                              decoration: InputDecoration(labelText: 'Title'),
                              focusNode: titleFocusNode,
                              controller: todoController),
                        ),
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
                      focusNode: commentFocusNode,
                      expands: true,
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText: 'Comment',
                        border: OutlineInputBorder(),
                      ),
                      controller: commentController,
                    ),
                  ),
                  titleFocusNode.hasFocus | commentFocusNode.hasFocus
                      ? StreamBuilder(
                          stream: todoCollection.snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (text == '' ||
                                snapshot.data.docs.where(query).length < 1) {
                              return Container();
                            } else {
                              return Container(
                                color: Colors.white,
                                child: ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        Divider(),
                                    itemCount:
                                        snapshot.data.docs.where(query).length,
                                    itemBuilder: (_, index) {
                                      return ListTile(
                                        title: FlatButton(
                                          color: Colors.white,
                                          onPressed: () {
                                            todoController.text = snapshot
                                                .data.docs
                                                .where(query)
                                                .toList()[index]
                                                .id;
                                          },
                                          child: Text(snapshot.data.docs
                                              .where(query)
                                              .toList()[index]
                                              .id),
                                        ),
                                      );
                                    }),
                              );
                            }
                          })
                      : Container(),
                ],
              ),
            ),
            commentFocusNode.hasFocus
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      confirmCommentButton(),
                    ],
                  )
                : Container(),
            commentFocusNode.hasFocus?Container():_imageFile != null
                ? Expanded(child: Image.file(_imageFile))
                : Container(),
            commentFocusNode.hasFocus
                ? Container()
                : RaisedButton(
                    onPressed:
                        this.todoController.text.length < 1 || isUploading
                            ? null
                            : () => addTodo(),
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

  confirmComment() {
    this.commentFocusNode.unfocus();
  }

  addTodo() async {
    setState(() {
      success = AddingTodo.LOADING;
    });
    if (_imageFile != null) {
      await uploadImage();
    }
    this
        .todoCollection
        .doc(todoController.text)
        .set({'title': todoController.text}).then((e) {
      this.todoCollection.doc(todoController.text).collection('entries').add({
        'date': DateTime.now(),
        'comment': this.commentController.text.length > 0
            ? this.commentController.text
            : '',
        'image': this.uploadurl != null ? uploadurl : ''
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

  Widget confirmTitleButton() {
    return FlatButton(
        onPressed: () => confirmTitle(),
        child: success == AddingTodo.LOADING
            ? CircularProgressIndicator()
            : Icon(Icons.check, color: Colors.green));
  }

  Widget confirmCommentButton() {
    return FlatButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: BorderSide(color: Colors.green, width: 3)),
        color: Colors.white,
        onPressed: () => confirmComment(),
        child: Icon(Icons.check, color: Colors.green));
  }
}
